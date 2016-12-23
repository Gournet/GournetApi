class AlergyByUser < ApplicationRecord

  belongs_to :user
  belongs_to :alergy
  
end
