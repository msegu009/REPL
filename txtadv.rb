def d(dice_sides)
	rand(1..dice_sides)
end

def prompt
	print "> "
	gets.chomp.downcase

end

class Hero

	attr_accessor :hp, :ac, :crit_chance, :hit_chance, :wisdom, :attack_range, :gold, :spells, :bow
	def initialize(hp, ac, attack_range, crit_chance, hit_chance, wisdom)
		@hp = hp
		@ac = ac
		@attack_range = attack_range
		@crit_chance = crit_chance
		@hit_chance = hit_chance
		@wisdom = wisdom
		@gold = 2
		@bow = false
		@spells = { heal: 1,
					fireball: 0,
					iron_skin: 0,
					c_speed: 0,
					rage: 0,
					dragon_potion: false
		}
	end

	def attack
		rand(@attack_range)
	end
end

module Action
	@spells = {	:fireball => "You gain a scroll of a Fireball spell (type 'fireball' to cast)\nIt is a damage spell.",
					:iron_skin => "You gain a scroll of a Iron Skin spell (type 'iron skin' to cast)\nIt will increase your armor class.",
					:c_speed => "You gain a scroll of a Speed spell (type 'speed' to cast)\nIt will increase your hit chance.",
					:rage => "You gain a scroll of a Rage spell (type 'rage' to cast)\nIt will increase your damage."
				}

	def Action.spell_table(hero)
		random_spell = @spells.to_a[rand(0..(@spells.length-1))][0]
		hero.spells[random_spell] += 1
		puts @spells[random_spell]
		@spells.delete(random_spell)
	end

	def Action.combat_prompt
		puts "Hit Enter for next round, type the spell name to cast a spell, type 'heal' to drink potion, or type q to exit."
		puts "type 'help' if you need some reminders..."
		print "> "
		gets.chomp.downcase
	end

	def Action.shoot_bow(monster, hero)
		puts "You draw your bow, and shoot an arrow before #{monster.name} can get to you!"
		if d(100) <= hero.crit_chance * 2
			bow_damage = rand(5..8)
			puts "Your arrows strikes #{monster.name} and you deal #{bow_damage} damage!"
			monster.hp = monster.hp - bow_damage
		else
			puts "#{monster.name} blocks your arrow!!!"
		end
		puts "#{monster.name} moves in for melee combat!"
	end

	def Action.list_spells(hero)
		help_msg = []
		if hero.spells[:fireball] > 0
			help_msg.push("fireball")
		end
		if hero.spells[:iron_skin] > 0
			help_msg.push("iron skin")
		end
		if hero.spells[:c_speed] > 0
			help_msg.push("speed")
		end
		if hero.spells[:rage] > 0
			help_msg.push("rage")
		end
		if help_msg == []
			puts "You do not have any spell scrolls right now..."
		else
			puts "You know how to cast the following spells: #{help_msg.join(", ")}."
		end
		if hero.spells[:heal] > 0
			puts "You have #{hero.spells[:heal]} health potions. Use 'heal' command to use!"
		else
			puts "You do not have any health potions!"
		end
		puts " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	end


	def Action.fireball(monster, hero)
		if hero.spells[:fireball] > 0
			hero.spells[:fireball] -= 1
			puts "You throw a massive ball of fire at your enemy! Whooozah!"
			fireball_damage = rand(4..11) + hero.wisdom
			puts "you hit #{monster.name} for #{fireball_damage} fire damage!"
			monster.hp = monster.hp - fireball_damage
		else
			puts "All scrolls are one-time use! You are not able to cast the spell again!"
		end
	end

	def Action.heal(hero)
		if hero.spells[:heal] > 0
			heal_amount = rand(9..20) + hero.wisdom
			hero.spells[:heal] -= 1
			puts "You quickly drink the healing potion and recover #{heal_amount}hp!"
			puts "Remaining number of health potions: #{hero.spells[:heal]}."
			hero.hp = hero.hp + heal_amount
		else
			puts "You don't have any health potions left!"
		end
	end

	def Action.iron_skin(hero)
		if hero.spells[:iron_skin] > 0
			hero.spells[:iron_skin] -= 1
			puts "Your skin becomes as tough as iron!"
			hero.ac += 2 + hero.wisdom
		else
			puts "All scrolls are one-time use! You are not able to cast the spell again!"
		end
	end

	def Action.rage(hero)
		if hero.spells[:rage] > 0
			hero.spells[:rage] -= 1
			puts "You are fueled with rage!!! You deal more damage!"
			hero.attack_range = (hero.attack_range.min + 1 + hero.wisdom)..(hero.attack_range.max + 1 + hero.wisdom)
		else
			puts "All scrolls are one-time use! You are not able to cast the spell again!"
		end
	end

	def Action.c_speed(hero)
		if hero.spells[:c_speed] > 0
			hero.spells[:c_speed] -= 1
			puts "Time slows down around you and you acquire precision of a ninja!"
			hero.hit_chance += 2 + hero.wisdom
		else
			puts "All scrolls are one-time use! You are not able to cast the spell again!"
		end
	end

	def Action.kill_monster(monster, hero)
		puts "\n= = = = = = =  V I C T O R Y  = = = = = = = = ="
		puts "You defeated #{monster.name}!"
		puts "You get #{monster.reward} gold!"
		hero.gold = hero.gold + monster.reward
	end

	def Action.combat(monster, hero)
		puts "--- #{monster.name}'s HP: #{monster.hp} || Hero's HP is #{hero.hp} ----"
		round = 1
		ac1, attack_range1, hit_chance1 = hero.ac, hero.attack_range, hero.hit_chance
		while monster.hp > 0 || hero.hp > 0
			choice = Action.combat_prompt
			while choice != ""
				if choice == "fireball"
					Action.fireball(monster, hero)
					if monster.hp <= 0
					Action.kill_monster(monster, hero)
					hero.ac, hero.attack_range, hero.hit_chance = ac1, attack_range1, 0
					return
					end
				choice = Action.combat_prompt
				elsif choice == "heal"
					Action.heal(hero)
					choice = Action.combat_prompt
				elsif choice == "iron skin"
					Action.iron_skin(hero)
					choice = Action.combat_prompt
				elsif choice == "rage"
					Action.rage(hero)
					choice = Action.combat_prompt
				elsif choice == "speed"
					Action.c_speed(hero)
					choice = Action.combat_prompt
				elsif choice == "help"
					Action.list_spells(hero)
					choice = Action.combat_prompt
				elsif choice =='q'
					puts 'Run, you coward!'
					exit(1)
				else
					puts "not sure how to do that."
					choice = Action.combat_prompt
				end
			end
			puts "\n<<<-------------| COMBAT ROUND ##{round.to_s} |------------->>>"
			round += 1
			hero_damage_this_round = hero.attack

			if d(20) + hero.hit_chance >= monster.ac
				if d(100) <= hero.crit_chance
					hero_damage_this_round = hero_damage_this_round * 2
					print "Critical Hit!!!"
				end
				puts "You hit the #{monster.name} for #{hero_damage_this_round}!"
				monster.hp = monster.hp - hero_damage_this_round
				if monster.hp <= 0
					Action.kill_monster(monster, hero)
					hero.ac, hero.attack_range, hero.hit_chance = ac1, attack_range1, hit_chance1
					break
				end
			else
				puts "#{monster.name} blocks your attack!"
			end

			monster_damage_this_round = monster.attack

			if d(20) + monster.hit_chance >= hero.ac
				if d(100) <= monster.crit_chance
					monster_damage_this_round = monster_damage_this_round * 2
					print "CRIT damage! "
				end
				puts "#{monster.name} hits you for #{monster_damage_this_round}!"
				hero.hp = hero.hp - monster_damage_this_round
				if hero.hp <= 0
					puts "You Died!"
					Death.new.enter(hero)
				end
			else
				puts "You successfully block #{monster.name}'s attack!"
			end

		puts "--- #{monster.name}'s HP: #{monster.hp} || Hero's HP is #{hero.hp} ----"
		end
	end
end


class Monster
	attr_reader :name, :ac, :reward, :crit_chance, :hit_chance
	attr_accessor :hp

	def initialize(name, options = {})
		@name = name
		@hp = options.fetch(:hp) {10}
		@attack_range = options.fetch(:attack_range) {1..3}
		@ac = options.fetch(:ac) { 8 }
		@reward = options.fetch(:reward) { 0 }
		@crit_chance = options.fetch(:crit_chance) { 5 }
		@hit_chance = options.fetch(:hit_chance) {0}
	end

	def attack
		rand(@attack_range)
	end
end


class Engine
	def initialize(first_event)
		@first_event = first_event
	end

	def play(hero)
		active_event = @first_event
		while true
			active_event = active_event.enter(hero)
		end
	end
end

class Event
	include Action
	def line
		puts "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
		print "PRESS ENTER TO CONTINUE IF YOU DARE!!!!\n >"
		gets.chomp.downcase
		puts
		
	end
end

class FirstFloor < Event
	def initialize
		@monster = Monster.new("The Old Goblin")
		@riddles = {"I only point in one direction, but I guide people around the world with perfection.\nWhat am I?" => "compass",
					"Alive without breath, as cold as death. Never thirsty, ever drinking.\nClad in mail, never clinking. What am I?" => "fish",
					"I am a container with no sides and no lid, yet golden treasure lays inside. What am I?" => "egg",
					"Feed me and I will live, give me water and I will die. What am I?" => "fire",
					"I have a head and a tail but no body...\nWhat am I?" => "coin"
					}
		@riddle = rand(0..4)
	end

	def enter(hero)
		line
		puts "You walk into a dimly lit room, and see an old goblin in the corner."
		puts "'Hello, traveler', the goblin said. 'My name is Buksa.'"
		puts "'Answer my riddle, and get a reward!'"
		puts "'Here is my riddle: #{@riddles.to_a[@riddle][0]}'"
		answer = prompt
		if answer == @riddles.to_a[@riddle][1]
			puts "'Very good, traveler!' Before you can say anything, Buksa dissapears..."
			puts "The old goblin leaves behind a health potion, 3 gold coins and a scroll."
			puts "You put the coins in your satchel along with the potion and scroll"
			Action.spell_table(hero)
			hero.gold = hero.gold + 3
			hero.spells[:heal] += 1
		else
			puts "I'm so sorry... '%s' is wrong!', snarks the Old Goblin!" % answer
			puts "'I appreciate the attempt, Here is 1 gold'"
			puts "The Goblin disappears and you put the coin in your satchel."
			hero.gold = hero.gold + 1
		end
		line
		puts "You see two doors that appear to be leading lower into the dungeon."
		puts "The right one has an engraved helm."
		puts "The left one has an engraving of a scroll etched into the door."
		puts "Which door do you choose: left or right?"
		choice = prompt
		while true
			if choice == "right"
				return TreasureRoom.new
			elsif choice == "left"
				return Library.new
			elsif choice == 'q'
				puts "Yeah, better to turn around now"
				exit(1)
			else
				puts "Sorry I am not sure what '%s' is. You may go right or left." % choice
				choice = prompt
			end
		end

	end


end

class Library < Event
	def initialize
		@monster = Monster.new("Draugr", {hp: 10, attack_range: 1..6, ac: 12, hit_chance: 2, reward: 2})
	end

	def enter(hero)
		puts "You walk into a dark room, there are shelves everywhere with dusty books."
		puts "It looks like an abandoned library."
		puts "You feel a freezing wind, and a scary Draugr appears in front of you!"
		puts "'Prepare to die, traveler!', #{@monster.name} growls."
		Action.combat(@monster, hero)
		line
		puts "After defeating the Draugr, you catch your breath and look around."
		puts "You hastily look through the room, and find two spell scrolls and some gold!"
		Action.spell_table(hero)
		Action.spell_table(hero)
		puts "Just as you getting ready to leave, you see another scroll in the back of a dusty shelf."
		puts "The inscription says \"Dragon Sleep Charm Spell\". Interesing... It might be useful!"
		puts "You grab it and walk out of the Library."
		hero.spells[:dragon_potion] = true
		line
		SecondFloor.new
	end
end

class TreasureRoom < Event
	def initialize
		@monster = Monster.new("Bandit Archer", {hp: 15, ac: 9, crit_chance: 15, reward: 2})
	end

	def enter(hero)
		puts "You carefully walk into the room. You see lots of weapons and shields on the walls."
		puts "It must be an armory of some sort. You are too late to notice a #{@monster.name} in the corner!"
		puts "You rush towards the archer, as he yells and releases an arrow!"
		if d(20) + 5 >= hero.ac
			archer_damage = rand(3..8)
			puts "The arrow hits you for #{archer_damage} damage!"
			hero.hp = hero.hp - archer_damage
		else
			puts "You block the arrow as you zig zag towards the #{@monster.name}!"
		end
		Action.combat(@monster, hero)
		puts "You pick up your enemy's bow! Nice! Now you can get at least one shot in from afar before combat!"
		hero.bow = true
		puts "You look around the treasure room! There has to be something here that can be useful!"
		puts "You grab a scimitar, a dwarven breastplate and a silver helmet! Nice!"
		puts "Your attack and armor class improved! You are ready!"
		hero.attack_range = (hero.attack_range.min + 2)..(hero.attack_range.max + 2)
		hero.ac += 3
		line
		SecondFloor.new
	end
end

class SecondFloor < Event
	def initialize
		@monster = Monster.new("Armored Troll", {hp: 14, attack_range: 3..5, ac: 13, crit_chance: 10, reward: 3})
	end

	def enter(hero)
		puts "You go deeper and deeper into the dungeon. You see a large silhouette that is blocking your path!"
		puts "It is an #{@monster.name} with a steel shield and a war axe. He grunts and moves towards you."
		Action.shoot_bow(@monster, hero) if hero.bow == true
		Action.combat(@monster, hero)
		puts "The #{@monster.name} was carrying a health potion and a spell scroll! Score!"
		hero.spells[:heal] += 1
		Action.spell_table(hero)
		puts "Time to see what this Troll was guarding!"
		line
		DragonNursery.new
	end
end

class DragonNursery < Event
	def initialize
		@monster = Monster.new("Baby Dragon", {hp: 15, attack_range: 2..8, ac: 12, crit_chance: 20})
	end

	def enter(hero)
		puts "You slowly open the door, and you see lots of gold everywhere! Treasure Room! Yes!"
		puts "You hear snoring in the corner. It is a baby dragon curled up sleeping! So cool!"
		puts "You have never seen a real one before! You run up to it, and start taking selfies with the dragon!"
		puts "You will get so many likes on Facebook! Unfortunately, this wakes the baby up! He is not happy!"
		line
		if hero.spells[:dragon_potion] == true
			puts "You better use the draconic sleep charm spell, or you might be this baby's breakfast!"
			puts "Say 'somnum' precisely to cast the spell!"
			cast = gets.chomp.downcase
			if cast == 'somnum'
				puts "The dragon looks at you, smiles, drools and falls asleep... Adorable!"
			else
				puts 'Oh no, you should have casted the spell with more care! It did not work! Bad news!'
				Action.shoot_bow(@monster, hero) if hero.bow == true
				Action.combat(@monster, hero)
			end
		else
			puts "Dragon charges, I think it wants to hurt you!"
			Action.shoot_bow(@monster, hero) if hero.bow == true
			Action.combat(@monster, hero)
		end
		line
		puts "You hear a deafening roar down the hallway!"
		puts "The Dragon Matriarch must have heard the commotion! You better get out of here FAST!"
		puts "You grab a handful of coins, and run down the first staircase you see!"
		puts  "Deeper into the dungeon you go!"
		line
		hero.gold += rand(4..6)
		TrapRoom.new
	end
end

class Shop < Event
	def initialize(hero)
		@shop = {"mace" => [-7, 0, 5, 5, 0, 0, "Daedric Mace"], "sword" => [-11, 0, 3, 4, 2, 10, "Ebony Sword"],
				 "shield" => [-7, 4, 0, 0, 0, 0, "Mirror Shield"], "boots" => [-5, 0, 0, 0, 4, 0, "Mercury's Treads"],
				 "ring" => [-5, 0, 0, 0, 0, 20, "Ring of Empowerment"], "potion" => [-1, 0, 0, 0, 0, 0, "a health potion"]}
		@offer = "Think wisely: MACE, SWORD, SHIELD, BOOTS, RING, POTION.\n Or type EXIT to finish shopping."
		@stats = [hero.gold, hero.ac, hero.attack_range.min, hero.attack_range.max, hero.hit_chance, hero.crit_chance]
	end

	def upgrade(item)
		@stats.map.with_index{|x, i| x + @shop[item][i]}
	end

	def not_enough_gold(item)
		puts "I am sorry, you can't afford that! You have #{@stats[0]} gold left."
		puts "The #{@shop[item][6]} costs #{@shop[item][0].abs}!"
	end

	def enter(hero)
		puts "You walk into a brightly lit room, and a large fluffy-looking creature waves to you!"
		puts "'Hello, traveler!', she says."
		puts "'This is a shop and it is open for business! Now you can spend all that gold that you are carrying!'"
		puts "'You are getting ready to face the boss, so you should buy something that will help you!'"
		puts "'Here is what I got! Everything is on sale!'"
		puts "1. Daedric Mace: It has super high damage! (7 gold)"
		puts "2. Ebony Sword: It has good damage, improves critical and hit chance! (11 gold)"
		puts "3. Mirror Shield: It will block most attacks! (7 gold)"
		puts "4. Mercury's Treads: You will be super fast, and you will be hard to block! (5 gold)"
		puts "5. Ring of Empowerment: You will have a higher chance of a critical damage! (5 gold)"
		puts "6. Health Potions: Good way to stay alive! (1 gold)"
		puts "You have #{hero.gold} to spend! Spend it wisely! You may buy multiple health potions!"
		puts @offer
		input = prompt
		 while input != "exit"
		 	if input == "potion"
		 		if @stats[0] + @shop[input][0] >= 0
			 		@stats[0] -= 1
			 		hero.spells[:heal] += 1
			 		puts "You purchased #{@shop[input][6]}! You have #{@stats[0]} gold left!"
			 	else
			 		not_enough_gold(input)
			 	end
		 	elsif @shop[input] != nil
		 		if @stats[0] + @shop[input][0] >= 0
			 		@stats = upgrade(input)
			 		puts "You purchased #{@shop[input][6]}! You have #{@stats[0]} gold left!"
			 	else
			 		not_enough_gold(input)
			 	end
			elsif input == 'q'
				puts "See you later!"
				exit(1)
		 	else
		 		puts "Sorry, I don't have '%s' for sale!" % input
		 		puts @offer
		 	end
		 	if @stats[0] == 0
		 		puts "Looks like you spent all your gold! Come back when you have more, okay?"
		 		break
		 	end
		 	input = prompt
		 end
		hero.gold, hero.ac, min_att, max_att, hero.hit_chance, hero.crit_chance = @stats
		hero.attack_range = min_att..max_att
		puts "Thanks for shopping at \"Gunja\'s Potions and Gear\"!"
		puts "Now go through that door and fight the Dungeon Boss!"
		line
		BossLair.new
	end
end

class TrapRoom < Event
	def enter(hero)
		puts "You walk into a large room with multiple columns and very high ceilings."
		line
		if d(9) <= hero.wisdom
			puts "You notice a triggering mechanism in the floor, and avoid setting\noff the trap, that was close!"
		elsif d(100) <= hero.crit_chance * 2
			puts "You should have been paying attention where you walk!"
			puts "You step on a triggering mechanism on the floor and a giant bolder crashes down."
			puts "Good thing, you have such quick reflexes!"
			puts "You roll away just in time to avoid getting smashed. Wheeew!!!"
		else
			puts "You should have been paying attention where you walk!"
			puts "You step on a triggering mechanism on the floor and a giant bolder crashes down."
			trap_damage = rand(3..10)
			puts "You clumsily try to get out of the harms way, but you are not fast enough!"
			puts "The boulder hits you and deals #{trap_damage} damage!"
			hero.hp = hero.hp - trap_damage
			if hero.hp <= 0
				puts "The damage was fatal... You were so close..."
				return Death.new
			end
			puts "You can't believe you survived this! "
		end
		line
		puts "You should get out of here, before something else terrible happens to you!"
		puts "You see a single door that is leading out of this area!"
		puts "Let's see what is behind it!"
		line
		Shop.new(hero)
	end
end

class BossLair < Event
	def initialize
		@monster = Monster.new("Daedric Prince", {hp: 50, attack_range: (3..8), ac: 12, crit_chance: 20, hit_chance: 2})
	end

	def enter(hero)
		puts "You walk into a large round room brightly lit by torches!"
		puts "It looks like an Arena! In the middle of it you see a looming evil Demon!"
		puts "He is surrounded by smoke and fire!'I am a Daedric Prince of Disorder and Chaos!'"
		puts "I will consume your soul!"
		line
		Action.shoot_bow(@monster, hero) if hero.bow == true
		Action.combat(@monster, hero)
		Victory.new
	end
end

class Victory < Event
	def enter(hero)
		puts "You defeated the Boss! I recommend playing Skyrim..."
		puts "I mean you won though! But seriously Skyrim is way better.."
		puts
		puts "================ G A M E    O V E R =================="
		puts "================== C R E D I T S ====================="
		puts "========  Designed and coded by Michael Segura  ======="
		exit(1)
	end
end

class Death < Event
	def initialize
		@deaths = [ "Noone will even remember your name...\nShould have stayed home today and played board games instead.",
					"You are very bad at this...\nMay I recommend a coloring book instead?",
					"Local rats are happy about this!\nThey will feast on your corpse for days... Nom nom..",
					"Don't feel bad, this game is really unbalanced...\nYou could try again if you are bored...",
					"As you bleed out and die, your only regret is that you\nnever got a chance to see DisneyWorld... :("
				]
	end

	def enter(hero)
		puts "======================================================"
		puts @deaths[rand(0..4)]
		puts "======= Y 0 U    A R E    D E A D ! ! ! =============="
		puts "============== G A M E    O V E R ===================="
		exit(1)
	end
end

puts "Welcome to the dungeon, brave hero!"
puts "Before you go, what Class do you want to specialize in?"
puts "Warrior: will improve your HP, Attack Strength and Armor Class."
puts "Rogue: will improve your Hit and Crit Chance, Bow skills and Avoiding Traps."
puts "Mage: will improve your spellcasting and Trap Detection."
print "> "
choice = gets.chomp.downcase
while true
	if choice == "warrior"
		s, d, w = 1, 0, 0
		break
	elsif choice == "rogue"
		s, d, w = 0, 2, 0
		break
	elsif choice == "mage"
		s, d, w = 0, 0, 4
		break
	elsif choice == 'q'
				puts "See you later!"
				exit(1)
	else
		puts "sorry but '%s' is not a valid Class" % choice
		print "> "
		choice = gets.chomp.downcase
	end
end

mike = Hero.new(30 + (s * 10), 9 + (s * 2), ((1 + s)..(3 + s)), 15 + (d * 10), 0 + d, 3 + w)
puts 'You have a shortsword, a wooden shield and one health potion.'
puts "Use 'help' command during combat to see your spells and potions."
puts "Good luck, brave hero!"
dungeon_engine = Engine.new(FirstFloor.new)
dungeon_engine.play(mike);