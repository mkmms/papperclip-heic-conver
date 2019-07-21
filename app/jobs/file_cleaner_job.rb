class FileCleanerJob < ApplicationJob
  queue_as :default

  def perform(*args)
		Rails.logger.info "===========File Deleting============="
		FileUtils.rm_rf(args[0])
		Rails.logger.info "===========File Deleted============="
  end
end
