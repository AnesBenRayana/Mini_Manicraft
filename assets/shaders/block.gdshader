shader_type spatial;

render_mode diffuse_burley, cull_back;

uniform int block_type = 0;

varying vec3 local_pos;


// =========================
// VERTEX
// =========================

void vertex() {
	local_pos = VERTEX;
}


// =========================
// RANDOM PIXEL VALUE
// =========================

float random_value(vec2 p) {

	return fract(
		sin(
			dot(
				p,
				vec2(12.9898, 78.233)
			)
		) * 43758.5453
	);
}


// =========================
// PIXEL COLOR VARIATION
// =========================

vec3 pixel_variation(
	vec3 base_color,
	vec2 uv
) {

	vec2 cell = floor(uv * 8.0);

	float random = random_value(cell);

	if (random > 0.80) {
		return base_color * 0.75;
	}

	if (random > 0.60) {
		return base_color * 0.88;
	}

	if (random < 0.15) {
		return base_color * 1.12;
	}

	return base_color;
}


// =========================
// FRAGMENT
// =========================

void fragment() {

	vec3 color;


	// =========================
	// GRASS BLOCK
	// =========================

	if (block_type == 0) {

		// TOP OF BLOCK
		if (NORMAL.y > 0.5) {

			color = pixel_variation(
				vec3(0.30, 0.65, 0.16),
				UV
			);

		}

		// SIDES
		else {

			// Small grass layer at the top
			if (local_pos.y > 0.25) {

				color = pixel_variation(
					vec3(0.27, 0.58, 0.13),
					UV
				);

			}

			// Dirt underneath
			else {

				color = pixel_variation(
					vec3(0.40, 0.25, 0.12),
					UV
				);
			}
		}
	}


	// =========================
	// DIRT BLOCK
	// =========================

	else if (block_type == 1) {

		color = pixel_variation(
			vec3(0.40, 0.25, 0.12),
			UV
		);
	}


	// =========================
	// WOOD BLOCK
	// =========================

	else if (block_type == 2) {

		color = pixel_variation(
			vec3(0.35, 0.18, 0.07),
			UV
		);
	}


	// =========================
	// LEAVES BLOCK
	// =========================

	else if (block_type == 3) {

		color = pixel_variation(
			vec3(0.05, 0.30, 0.04),
			UV
		);
	}


	// =========================
	// PLAYER PLACED BLOCK
	// =========================

	else if (block_type == 4) {

		color = pixel_variation(
			vec3(0.32, 0.14, 0.05),
			UV
		);
	}


	// =========================
	// FINAL MATERIAL
	// =========================

	ALBEDO = color;

	ROUGHNESS = 1.0;
}