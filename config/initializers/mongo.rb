# Set same log level for mongoid and mongodb ass application
Mongoid.logger.level = Rails.logger.level
Mongo::Logger.logger.level = Rails.logger.level