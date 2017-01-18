module ControllerUtility

  def record_not_found
    render json: {data: {
        status: "Error",
        error: "We can't find the record"
      }
    },status: :gone
  end

  def record_error
    render json: { data: {
        status: "Error",
        error: "We can't delete the record"
      }
    }, status: :internal_server_error
  end

  def set_pagination(params)
    if params.has_key?(:page)
      @page = params[:page].has_key?(:number) ? params[:page][:number].to_i : 1
      @per_page = params[:page].has_key?(:size) ?  params[:page][:size].to_i : 10
    end
    @page ||= 1
    @per_page ||= 10
  end

  def set_orders(params,query)
    if params.has_key?(:sort)
      values = params[:sort].split(",")
      values.each  do |val|
        query = set_order(val,query)
      end
    end
    query
  end

  def set_include(params)
    temp = params[:include]
    temp ||= "*"
    if temp.include? "**"
      temp = "*"
    end
    @include = temp
  end

  def record_add_rating
    render json: { data: {
        status: "Error",
        error: "You need first to order this dish, if you want to vote"
      }
    }, status: :forbidden
  end

  def can_operation
    render json: { data: {
        status: "Success"
      }
    }, status: :ok
  end

  def cannot_operation
    render json: { data: {
        status: "Error",
        error: "You need first to order this dish, if you want to vote"
      }
    }, status: :forbidden
  end

  def record_add_comment
    render json: { data: {
        status: "Error",
        error: "You need first to order this dish, if you want to vote"
      }
    }, status: :forbidden
  end

  def operation_not_allowed
    render json: { data: {
        status: "Error",
        errors: ["We can't make this operation on the record",
        "You are not the owner of this record"]
      }
    },status: :unauthorized
  end

  def order_errors
    render json: { data: {
        status: "Error",
        errors: ["We can't create the order",
        "The address doesn't correspond to the user"]
      }
    },status: :forbidden
  end

  def order_quantity_errors
    render json: { data: {
        status: "Error",
        errors: ["We can't create the order",
        "The requested quantity is bigger than the available for the day"]
      }
    },status: :forbidden
  end

  def order_dish_errors
    render json: { data: {
        status: "Error",
        errors: ["We can't create the order",
        "The dish doesn't correspond to the chef"]
      }
    },status: :forbidden
  end

  def record_errors(record)
    render json: {data: {
        status: "Error",
        errors: record.errors.to_hash.merge(full_messages: record.errors.full_messages)
      }
    }, status: :unprocessable_entity
  end

  def record_success
    head :no_content
  end

  def set_fields(params)
    array = params[:fields].split(",") if params.has_key?(:fields)
    array ||= []
    array_s = nil
    if !array.empty?
      array_s = []
    end
    array.each do |a|
      array_s.push(a.to_sym)
    end
    array_s
  end

  def meta_attributes(resource, extra_meta = {})
    {
      current_page: resource.current_page,
      current_size: resource.per_page(nil),
      next_page: resource.next_page,
      prev_page: resource.previous_page, # use resource.previous_page when using will_paginate
      total_pages: resource.total_pages,
      total_count: resource.total_entries
    }.merge(extra_meta)
  end
end
