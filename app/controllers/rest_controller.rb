class RestController < ApplicationController
  before_action :get_object, except: [ :index ]

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
    id = params[:id]

    status = begin
      if @object
        if request.put?
          get_table.replace(
            safe_params.merge(
              id: id,
              created_at: Time.now,
              updated_at: Time.now
            ).merge(parents)
          ).run(@conn)

          :ok
        elsif request.patch?
          get_table.update(
            safe_params.merge(
              id: id,
              updated_at: Time.now
            )
          ).run(@conn)

          :ok
        elsif request.delete?
          get_table.get(@object["id"]).delete(
            :durability => "hard", :return_vals => false
          ).run(@conn)

          :no_content
        end
      else
        if request.put?
          get_table.insert(
            safe_params.merge(
              id: id,
              created_at: Time.now,
              updated_at: Time.now
            ).merge(parents)
          ).run(@conn)

          :created
        else
          :not_found
        end
      end
    rescue Exception => e
      puts e.message
      :internal_server_error
    end

    if status == :created or status == :ok
      get_object
      render json: { collection.to_sym => @object },
        status: status, location: some_url(id)
    else
      head status
    end
  end

  protected

  def collection
    params[:controller]
  end

  def safe_params
    {}
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
    @object = get_table.filter(parents.merge({id: params[:id]})).pluck(attrs).run(@conn).first
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
