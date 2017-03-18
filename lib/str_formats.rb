module StrFormats

	def getFormattedLike(str)
		return ActiveSupport::Inflector.transliterate(str.strip).to_s.downcase
	end
end