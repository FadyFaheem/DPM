# Converts real elapsed time into game time. The scale is configurable so the
# game can run at a relaxed pace in production and be accelerated in tests.
module GameClock
  DAYS_PER_MONTH = 30.0

  module_function

  def real_minutes_per_game_day
    ENV.fetch("GAME_DAY_REAL_MINUTES", "60").to_f
  end

  def game_days_between(from, to)
    return 0.0 if from.nil? || to.nil?

    (to - from) / (real_minutes_per_game_day * 60)
  end

  def age_months(born_at, now = Time.current)
    game_days_between(born_at, now) / DAYS_PER_MONTH
  end
end
