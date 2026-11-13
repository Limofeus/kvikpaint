@tool
class_name LaTeXSyntaxHighlighter
extends SyntaxHighlighter
## Custom SyntaxHighlighter Resource for LaTeX math expressions in Godot 4 TextEdit / CodeEdit nodes.
## Exposes @export Color properties for commands, Greek/math symbols, environments (\begin/\end),
## comments (%), alignment/linebreak tokens (& / \\), braces/brackets, scripts (^ / _), operators, and numbers.

@export_group("LaTeX Highlight Colors")

@export var text_color: Color = Color(0.92, 0.94, 0.98, 1.0):
	set(value):
		text_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var comment_color: Color = Color(0.42, 0.62, 0.96, 1.0):
	set(value):
		comment_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var environment_command_color: Color = Color(0.95, 0.42, 0.45, 1.0):
	set(value):
		environment_command_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var environment_name_color: Color = Color(0.28, 0.82, 0.80, 1.0):
	set(value):
		environment_name_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var command_color: Color = Color(0.35, 0.84, 0.52, 1.0):
	set(value):
		command_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var symbol_color: Color = Color(0.94, 0.56, 0.72, 1.0):
	set(value):
		symbol_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var line_break_color: Color = Color(0.68, 0.58, 0.98, 1.0):
	set(value):
		line_break_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var brace_color: Color = Color(0.96, 0.78, 0.36, 1.0):
	set(value):
		brace_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var operator_color: Color = Color(0.48, 0.78, 0.98, 1.0):
	set(value):
		operator_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

@export var number_color: Color = Color(0.98, 0.66, 0.38, 1.0):
	set(value):
		number_color = value
		if get_text_edit() != null:
			clear_highlighting_cache()

const ENV_COMMANDS: Dictionary = {
	"begin": true,
	"end": true,
	"left": true,
	"right": true,
	"big": true, "Big": true, "bigg": true, "Bigg": true,
	"bigl": true, "Bigl": true, "biggl": true, "Biggl": true,
	"bigr": true, "Bigr": true, "biggr": true, "Biggr": true,
}

const SYMBOL_COMMANDS: Dictionary = {
	# Greek letters
	"alpha": true, "beta": true, "gamma": true, "delta": true, "epsilon": true,
	"varepsilon": true, "zeta": true, "eta": true, "theta": true, "vartheta": true,
	"iota": true, "kappa": true, "varkappa": true, "lambda": true, "mu": true,
	"nu": true, "xi": true, "omicron": true, "pi": true, "varpi": true,
	"rho": true, "varrho": true, "sigma": true, "varsigma": true, "tau": true,
	"upsilon": true, "phi": true, "varphi": true, "chi": true, "psi": true, "omega": true,
	"Gamma": true, "Delta": true, "Theta": true, "Lambda": true, "Xi": true,
	"Pi": true, "Sigma": true, "Upsilon": true, "Phi": true, "Psi": true, "Omega": true,
	# Logic, set, arrow & calculus symbols
	"infty": true, "partial": true, "nabla": true, "forall": true, "exists": true,
	"nexists": true, "emptyset": true, "varnothing": true, "neg": true, "lnot": true,
	"hbar": true, "ell": true, "wp": true, "Re": true, "Im": true, "aleph": true,
	"beth": true, "prime": true, "top": true, "bot": true, "angle": true,
	"triangle": true, "square": true, "Box": true, "blacksquare": true, "lozenge": true,
	"Diamond": true, "surd": true, "dagger": true, "ddagger": true, "therefore": true,
	"because": true, "dots": true, "ldots": true, "cdots": true, "vdots": true, "ddots": true,
	"pm": true, "mp": true, "times": true, "div": true, "cdot": true, "ast": true,
	"star": true, "circ": true, "bullet": true, "oplus": true, "ominus": true,
	"otimes": true, "oslash": true, "odot": true, "cap": true, "cup": true,
	"vee": true, "lor": true, "wedge": true, "land": true, "setminus": true,
	"leq": true, "le": true, "leqslant": true, "geq": true, "ge": true, "geqslant": true,
	"neq": true, "ne": true, "equiv": true, "approx": true, "sim": true, "simeq": true,
	"cong": true, "propto": true, "ll": true, "gg": true, "prec": true, "succ": true,
	"preceq": true, "succeq": true, "subset": true, "supset": true, "subseteq": true,
	"supseteq": true, "in": true, "notin": true, "ni": true, "owns": true,
	"vdash": true, "dashv": true, "models": true, "perp": true, "parallel": true, "mid": true,
	"to": true, "rightarrow": true, "leftarrow": true, "leftrightarrow": true,
	"Rightarrow": true, "implies": true, "Leftarrow": true, "impliedby": true,
	"Leftrightarrow": true, "iff": true, "mapsto": true, "longmapsto": true,
	"longrightarrow": true, "longleftarrow": true, "longleftrightarrow": true,
	"Longrightarrow": true, "Longleftarrow": true, "Longleftrightarrow": true,
	"langle": true, "rangle": true, "lceil": true, "rceil": true, "lfloor": true, "rfloor": true,
}

static func _is_ascii_alpha(code: int) -> bool:
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122)

static func _is_digit(code: int) -> bool:
	return code >= 48 and code <= 57

func _get_line_syntax_highlighting(p_line: int) -> Dictionary:
	var result: Dictionary = {}
	var te: TextEdit = get_text_edit()
	if te == null:
		return result

	var line: String = te.get_line(p_line)
	var n: int = line.length()
	if n == 0:
		return result

	var i: int = 0
	var last_color: Color = Color(-1.0, -1.0, -1.0, -1.0)

	while i < n:
		var ch: String = line[i]
		var code: int = line.unicode_at(i)

		# 1. Unescaped % comment to end of line
		if ch == "%":
			result[i] = {"color": comment_color}
			break

		# 2. Backslash command or escape sequence
		if ch == "\\":
			if i + 1 < n and line[i + 1] == "\\":
				result[i] = {"color": line_break_color}
				last_color = line_break_color
				i += 2
				continue

			var cmd_start: int = i
			i += 1
			if i < n and not _is_ascii_alpha(line.unicode_at(i)):
				var esc_ch: String = line[i]
				var c_col: Color = brace_color if (esc_ch == "{" or esc_ch == "}") else command_color
				result[cmd_start] = {"color": c_col}
				last_color = c_col
				i += 1
				continue

			var name_start: int = i
			while i < n and _is_ascii_alpha(line.unicode_at(i)):
				i += 1
			var cmd_name: String = line.substr(name_start, i - name_start)

			var chosen_col: Color = command_color
			if ENV_COMMANDS.has(cmd_name):
				chosen_col = environment_command_color
			elif SYMBOL_COMMANDS.has(cmd_name):
				chosen_col = symbol_color

			result[cmd_start] = {"color": chosen_col}
			last_color = chosen_col

			# If \begin{env} or \end{env}, highlight the environment name inside {...}
			if (cmd_name == "begin" or cmd_name == "end") and i < n and line[i] == "{":
				result[i] = {"color": brace_color}
				i += 1
				var env_start: int = i
				while i < n and line[i] != "}":
					i += 1
				if i > env_start:
					result[env_start] = {"color": environment_name_color}
				if i < n and line[i] == "}":
					result[i] = {"color": brace_color}
					last_color = brace_color
					i += 1
			continue

		# 3. Alignment tab &
		if ch == "&":
			result[i] = {"color": line_break_color}
			last_color = line_break_color
			i += 1
			continue

		# 4. Braces, brackets, parentheses
		if ch == "{" or ch == "}" or ch == "[" or ch == "]" or ch == "(" or ch == ")":
			result[i] = {"color": brace_color}
			last_color = brace_color
			i += 1
			continue

		# 5. Scripts and math operators
		if ch == "^" or ch == "_" or ch == "=" or ch == "+" or ch == "-" or ch == "*" or ch == "/" or ch == "<" or ch == ">" or ch == "|" or ch == "$":
			result[i] = {"color": operator_color}
			last_color = operator_color
			i += 1
			continue

		# 6. Numbers
		if _is_digit(code):
			var num_start: int = i
			while i < n and (_is_digit(line.unicode_at(i)) or line[i] == "."):
				i += 1
			result[num_start] = {"color": number_color}
			last_color = number_color
			continue

		# 7. Default text / identifiers / BMP characters
		if last_color != text_color:
			result[i] = {"color": text_color}
			last_color = text_color
		i += 1

	return result
