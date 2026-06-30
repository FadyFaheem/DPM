module Simulation
  # Compute-on-read entry point: advances every living dino and applies passive
  # income before the player's state is read.
  class ParkTick
    def self.call(player, now: Time.current)
      player.dinosaurs.alive.find_each { |dino| DinoTick.call(dino, now:) }
      Economy.passive_income(player, now:)
      player
    end
  end
end
