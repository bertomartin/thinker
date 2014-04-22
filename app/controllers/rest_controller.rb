class RestController < ApplicationController
  before_action :get_object, except: [ :index ]

  def index
    render json: { collection.to_sym => get_records }
  end

  def update
    id = params[:id]

    status = begin
      if request.put?
        if @object
          get_table.replace(
            safe_params.merge(
              id: id,
              created_at: Time.now,
              updated_at: Time.now
            ).merge(parents)
          ).run(@conn)
          :ok
        else
          get_table.insert(
            safe_params.merge(
              id: id,
              created_at: Time.now,
              updated_at: Time.now
            ).merge(parents)
          ).run(@conn)
          :created
        end
      elsif request.patch?
        if @object
          get_table.update(
            safe_params.merge(
              id: id,
              updated_at: Time.now
            )
          ).run(@conn)
          :ok
        else
          :not_found
        end
      end
    rescue
      :internal_server_error
    end

    if status == :not_found or status == :internal_server_error
      head status
    else
      get_object
      render json: { collection.to_sym => @object },
        status: status, location: some_url(id)
    end
  end

  def destroy
    head begin
      if @object
        get_table.get(@object["id"]).delete(
          :durability => "hard", :return_vals => false
        ).run(@conn)
        :no_content
      else
        :not_found
      end
    rescue
      :internal_server_error
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
    if params[:ids]
      qry.get_all(*params[:ids].split(","))
    else
      qry.limit(100)
    end
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

  def get_records
    qry = get_table
    qry = sort(qry) if params[:sort]

    filter(select(qry)).pluck(attrs).run(@conn).map do |record|
      record.merge(href: some_url(record["id"]))
    end
  end

  def get_object
    @object = get_table.filter(parents.merge({id: params[:id]})).run(@conn).first
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
