# Refactor of a legacy procedural dino-management script.
#
# Given a list of dino hashes ({ "category", "diet", "age", ... }) it returns a
# per-dino report (classic health from age + diet match, an Alive/Dead comment,
# and an age metric) plus a category-count summary -- without mutating its input.
class DinoReport
  PREFERRED_DIET = { "herbivore" => "plants", "carnivore" => "meat" }.freeze

  def self.call(dinos)
    new(dinos).call
  end

  def initialize(dinos)
    @dinos = Array(dinos)
  end

  def call
    reported = @dinos.map { |dino| report_for(dino) }
    { dinos: reported, summary: count_by_category(reported) }
  end

  private

  def report_for(dino)
    health = health_for(dino)
    alive = health.positive?

    dino.merge(
      "health" => health,
      "comment" => alive ? "Alive" : "Dead",
      "age_metrics" => age_metrics_for(dino["age"].to_i, alive)
    )
  end

  def health_for(dino)
    age = dino["age"].to_i
    return 0 if age <= 0

    base = 100 - age
    eating_preferred_diet?(dino) ? base : base / 2
  end

  # An unknown category has no diet requirement, so it counts as preferred.
  def eating_preferred_diet?(dino)
    preferred = PREFERRED_DIET[dino["category"]]
    preferred.nil? || dino["diet"] == preferred
  end

  def age_metrics_for(age, alive)
    return 0 unless alive && age > 1

    age / 2
  end

  def count_by_category(dinos)
    dinos.group_by { |dino| dino["category"] }.transform_values(&:size)
  end
end
