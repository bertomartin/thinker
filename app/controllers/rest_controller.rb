require 'errors'

class RestController < ApplicationController
  include Errors

  def index
    begin
      render json: { collection.to_sym => get_records }
    rescue Exception => e
      case e.message
      when "bad_request"
        head :bad_request
      else
        head :internal_server_error
      end
    end
  end

  def update
    begin
      status = if @object = get_object
        if request.put?
          replace_object
        elsif request.patch?
          update_object
        elsif request.delete?
          delete_object
        end
      else
        if request.put?
          insert_object
        else
          :not_found
        end
      end

      if status == :ok or status == :created
        render json: { collection.to_sym => get_object },
          status: status, location: some_url(params[:id])
      else
        head status
      end
    rescue ValidationError => e
      render json: {
        message: e.message,
        errors: e.errors
      }, status: :unprocessable_entity
    rescue Exception => e
      render json: { message: e.message }, status: :internal_server_error
    end
  end

  protected

  def safe_params
    {}
  end

  def insert_object
    get_table.insert(
      safe_params.merge(
        id: params[:id],
        created_at: Time.now,
        updated_at: Time.now
      ).merge(parents)
    ).run(@conn)
    :created
  end

  def update_object
    get_table.update(
      safe_params.merge(
        id: params[:id],
        updated_at: Time.now
      )
    ).run(@conn)
    :ok
  end

  def replace_object
    get_table.replace(
      safe_params.merge(
        id: params[:id],
        created_at: Time.now,
        updated_at: Time.now
      ).merge(parents)
    ).run(@conn)
    :ok
  end

  def delete_object
    get_table.get(params[:id]).delete(
      :durability => "hard", :return_vals => false
    ).run(@conn)
    :no_content
  end

  def collection
    params[:controller]
  end

  def get_table
    @r.table(collection)
  end

  def sort(qry)
    ordering = params[:sort].split(",").map do |attr|
      if attr[0] == "-"
        @r.desc(attr[1..-1].to_sym)
      else
        @r.asc(attr.to_sym)
      end
    end

    qry.order_by(*ordering)
  end

  def select(qry)
    qry = qry.get_all(*params[:ids].split(",")) if params[:ids]
    qry
  end

  def parents
    params.select {|k,v| k.match(/\A[a-z0-9_]+_id\z/i) }.compact
  end

  def filter(qry)
    parents.empty? ? qry : qry.filter(parents)
  end

  def attrs
    [ :id ]
  end

  def get_range(qry)
    begin
      range = request.headers[:HTTP_RANGE].split("=")[1].split("-")

      qry.skip(range[0].to_i).limit(range[1].to_i - range[0].to_i)
    rescue Exception => e
      raise Exception.new(:bad_request)
    end
  end

  def get_records
    qry = get_table
    qry = sort(qry) if params[:sort]

    fields = if params[:fields]
      params[:fields].split(",").map {|f| f.to_sym }.select do |field|
        attrs.include? field
      end
    else
      attrs
    end

    qry = filter(select(qry)).pluck(fields)
    qry = get_range(qry) if request.headers[:HTTP_RANGE]

    qry.run(@conn).map do |record|
      record.merge(href: some_url(record["id"]))
    end
  end

  def get_object
    get_table.filter(parents.merge({id: params[:id]})).pluck(attrs).run(@conn).first
  end

  def some_url(id)
    Rails.application.routes.default_url_options[:host] = request.host_with_port

    p = parents

    if p.empty?
      Rails.application.routes.url_helpers.send("some_#{collection}_url", id)
    else
      k = p.keys.first
      Rails.application.routes.url_helpers.send("some_#{k[0..-4]}_#{collection}_url", p[k], id)
    end
  end
end
