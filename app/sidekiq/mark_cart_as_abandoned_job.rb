class MarkCartAsAbandonedJob
  include Sidekiq::Job

  queue_as :default

  def perform
    mark_abandoned_carts
    delete_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    carts_to_abandon = Cart.ready_to_abandon
    carts_to_abandon.find_each(&:mark_as_abandoned)
    Rails.logger.info "[MARK_AS_ABANDONED] Marked carts as abandoned"
  end

  def delete_old_abandoned_carts
    carts_to_delete = Cart.ready_to_delete
    count = carts_to_delete.count
    carts_to_delete.destroy_all

    Rails.logger.info "[DELETE_OLD_ABANDONED_CARTS] Deleted #{count} abandoned carts"
  end
end
