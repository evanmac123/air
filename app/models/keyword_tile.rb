class KeywordTile < Tile
  def points
    first_rule.points
  end

  def form_builder_class
    TileBuilderForm::Keyword
  end
end
