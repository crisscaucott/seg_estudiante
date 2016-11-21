class Reporte < ActiveRecord::Base
	# dragonfly_accessor :nombre_reporte

	validates :nombre_reporte, presence: true

	# validates_size_of :nombre_reporte, maximum: 2.megabytes,
	                    # message: "should be no more than 2 MB", if: :image_changed?

	# validates_property :format, of: :image, in: [:jpeg, :jpg, :png, :bmp], case_sensitive: false,
	#                      message: "should be either .jpeg, .jpg, .png, .bmp", if: :image_changed?
end
