extends Node

var gravity = 9.8
var isVowelWindow = [ false, true ]
var letterPool = []
var letterCounts = [
	9, # A
	2, # B
	2, # C
	4, # D
	12, # E
	2, # F
	3, # G
	2, # H
	9, # I
	0, # J
	0, # K
	4, # L
	2, # M
	6, # N
	8, # O
	2, # P
	0, # Q
	6, # R
	4, # S
	6, # T
	4, # U
	0, # V
	2, # W
	0, # X
	2, # Y
	0, # Z
]

var vowels = [ "A", "E", "I", "O", "U" ]

var dict : Dictionary

func populate_letterPool():
	for i in GlobalConstants.letterCounts.size():
		var count = GlobalConstants.letterCounts[i]
		var conv = PoolByteArray()
		conv.append(65 + i)
		var letter = conv.get_string_from_ascii()
		for j in count:
			GlobalConstants.letterPool.push_back(letter)
