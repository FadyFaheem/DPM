module Simulation
  # Compute-on-read food production: each building accrues
  # base_output_per_day * level * elapsed-game-days into its matching food store.
  # Only whole game-days are paid out, and exactly those days are added back to
  # last_collected_at so sub-day remainders carry to the next read (no silent loss).
  class FoodCollection
    def self.call(player, now: Time.current)
      new(player, now).call
    end

    def initialize(player, now)
      @player = player
      @now = now
    end

    def call
      gains = Hash.new(0)
      @player.food_productions.find_each do |building|
        column, amount = accrue(building)
        gains[column] += amount if amount.positive?
      end
      apply(gains)
      gains
    end

    private

    def accrue(building)
      spec = FoodProductionCatalog.find(building.kind)
      return [ nil, 0 ] unless spec

      since = building.last_collected_at || building.created_at
      days = GameClock.game_days_between(since, @now).floor
      return [ spec.food_column, 0 ] if days <= 0

      building.update!(last_collected_at: since + GameClock.real_seconds_for_game_days(days))
      [ spec.food_column, spec.base_output_per_day * building.level * days ]
    end

    def apply(gains)
      return if gains.empty?

      attrs = gains.each_with_object({}) do |(column, amount), acc|
        acc[column] = @player.public_send(column) + amount
      end
      @player.update!(attrs)
    end
  end
end
