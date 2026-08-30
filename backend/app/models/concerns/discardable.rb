# frozen_string_literal: true

# Soft delete via the Discard gem. Records are marked with discarded_at
# instead of being destroyed; hard purge happens via CleanupDiscardedRecordsJob.
module Discardable
    extend ActiveSupport::Concern

    included do
        include Discard::Model

        self.discard_column = :discarded_at
    end
end
