extends Control

# --- CONSTANTS ---
const MAX_LIFE := 5
const MAX_LEVEL := 5
const SCORE_PER_MONSTER := 100

const BLOCK_GRAY = preload("res://blocks/gray.png")
const BLOCK_GREEN = preload("res://blocks/green.png")
const BLOCK_YELLOW = preload("res://blocks/yellow.png")

const HEART_FULL = preload("res://HP/heart_full.png")
const HEART_EMPTY = preload("res://HP/heart_empty.png")

const ENEMY_IMAGES = [
	null,
	preload("res://enemies/enemy1.png"),
	preload("res://enemies/enemy2.png"),
	preload("res://enemies/enemy3.png"),
	preload("res://enemies/enemy4.png"),
	preload("res://enemies/enemy5.png")
]

const LETTER_IMAGES := {
	"A": preload("res://letters/A.png"),
	"B": preload("res://letters/B.png"),
	"C": preload("res://letters/C.png"),
	"D": preload("res://letters/D.png"),
	"E": preload("res://letters/E.png"),
	"F": preload("res://letters/F.png"),
	"G": preload("res://letters/G.png"),
	"H": preload("res://letters/H.png"),
	"I": preload("res://letters/I.png"),
	"J": preload("res://letters/J.png"),
	"K": preload("res://letters/K.png"),
	"L": preload("res://letters/L.png"),
	"M": preload("res://letters/M.png"),
	"N": preload("res://letters/N.png"),
	"O": preload("res://letters/O.png"),
	"P": preload("res://letters/P.png"),
	"Q": preload("res://letters/Q.png"),
	"R": preload("res://letters/R.png"),
	"S": preload("res://letters/S.png"),
	"T": preload("res://letters/T.png"),
	"U": preload("res://letters/U.png"),
	"V": preload("res://letters/V.png"),
	"W": preload("res://letters/W.png"),
	"X": preload("res://letters/X.png"),
	"Y": preload("res://letters/Y.png"),
	"Z": preload("res://letters/Z.png")
}

var level := 1
var player_life := MAX_LIFE
var enemy_life := 1
var score := 0

var current_row := 0
var current_col := 0
var answer := ""
var word_list := []
var heart_scene := preload("res://HP/heart_icon.tscn")

func _ready():
	_load_words()
	_init_hearts()
	_start_level()

func _load_words():
	var file = FileAccess.open("res://words.txt", FileAccess.READ)
	while not file.eof_reached():
		word_list.append(file.get_line().to_upper())

func _start_level():
	player_life = MAX_LIFE
	enemy_life = level
	_update_hearts()
	$EnemySprite.texture = ENEMY_IMAGES[level]
	_new_word_round()

func _new_word_round():
	answer = word_list[randi() % word_list.size()]
	print("ANSWER:", answer) # remove later
	_clear_board()
	current_row = 0
	current_col = 0

func _game_over():
	get_tree().change_scene_to_file("res://ui/game_over.tscn")

func _win_game():
	get_tree().change_scene_to_file("res://ui/you_win.tscn")

# =============== INPUT ===============

func _input(event):
	if event is InputEventKey and event.pressed:
		var k = OS.get_keycode_string(event.keycode)

		if k == "Backspace": _remove_letter()
		elif k == "Enter": _submit_word()
		elif k.length() == 1 and k.is_valid_identifier():
			_add_letter(k.to_upper())


func _add_letter(letter):
	if current_col >= 5: return
	var slot = _slot(current_row, current_col)
	var letter_node = slot.get_node("Letter")
	letter_node.texture = LETTER_IMAGES[letter]
	slot.set_meta("char", letter)
	slot.set_meta("state", "filled")
	current_col += 1

func _remove_letter():
	if current_col == 0: return
	current_col -= 1
	var slot = _slot(current_row, current_col)
	var letter_node = slot.get_node("Letter")
	letter_node.texture = null
	slot.set_meta("char", "")

# =============== WORD CHECK ===============

func _submit_word():
	if current_col < 5: 
		print("not enough letters")
		return

	var guess := ""
	for i in range(5):
		guess += _slot(current_row, i).get_meta("char")

	_guess_feedback()
	_check_result(guess)
	
func _guess_feedback():
	var answer_chars = answer.split("")
	var counts = {}

	for c in answer_chars:
		counts[c] = counts.get(c, 0) + 1

	# First pass (greens)
	for i in range(5):
		var slot = _slot(current_row, i)
		var block = slot.get_node("Block")
		var g = slot.get_meta("char")

		if g == answer[i]:
			block.texture = BLOCK_GREEN
			counts[g] -= 1
		else:
			slot.set_meta("pending", true)

	# Second pass (yellow / gray)
	for i in range(5):
		var slot = _slot(current_row, i)
		if not slot.get_meta("pending"): continue

		var block = slot.get_node("Block")
		var g = slot.get_meta("char")

		if g in counts and counts[g] > 0:
			block.texture = BLOCK_YELLOW
			counts[g] -= 1
		else:
			block.texture = BLOCK_GRAY

func _check_result(guess:String):
	if guess == answer:
		enemy_life -= 1
		player_life = MAX_LIFE
		score += SCORE_PER_MONSTER
		_update_hearts()

		if enemy_life <= 0:
			level += 1
			if level > MAX_LEVEL:
				_win_game()
			else:
				_start_level()
		else:
			_new_word_round()
	else:
		current_row += 1
		current_col = 0
		player_life -= 1
		_update_hearts()
		if player_life <= 0:
			_show_correct_word()
			_game_over()

func _show_correct_word():
	print("Correct answer was:", answer)


# =============== UI HELPERS ===============
func _init_hearts():
	# Player hearts
	for i in range(MAX_LIFE):
		var heart = TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		$PlayerHearts.add_child(heart)

	# Enemy hearts
	for i in range(MAX_LEVEL):
		var heart = TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		$EnemyHearts.add_child(heart)

func _update_hearts():
	for i in range(MAX_LIFE):
		$PlayerHearts.get_child(i).texture = HEART_FULL if i < player_life else HEART_EMPTY
	for i in range(MAX_LEVEL):
		$EnemyHearts.get_child(i).texture = HEART_FULL if i < enemy_life else HEART_EMPTY

func _slot(r,c):
	if r < $Rows.get_child_count():
		var row = $Rows.get_child(r)
		if c < row.get_child_count():
			return row.get_child(c)
	return null

func _clear_board():
	for r in range(5):
		for c in range(5):
			var s = _slot(r, c)
			if s:
				s.get_node("Letter").texture = null
				s.get_node("Block").texture = BLOCK_GRAY
				s.set_meta("char", "")
				s.set_meta("state", "empty")
				s.set_meta("pending", false)
