module ControllerUtility

  def record_not_found
    render json: {data: {
        status: "Error",
        error: "We can't find the record"
      }
    },status: :not_found
  end

  def record_error
    render json: { data: {
        status: "Error",
        error: "We can't delete the record"
      }
    }, status: :internal_server_error
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
        "The address doen't correspond to the user"]
      }
    },status: :unauthorized
  end

  def order_quantity_errors
    render json: { data: {
        status: "Error",
        errors: ["We can't create the order",
        "The requested quantity is bigger than the available for the day"]
      }
    },status: :unauthorized
  end

  def order_dish_errors
    render json: { data: {
        status: "Error",
        errors: ["We can't create the order",
        "The dish doesn't correspond to the chef"]
      }
    },status: :unauthorized
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
