.extern _start

.global _reset_vector

.code 32
.section .text_reset_vector

_reset_vector:
	b _start

.end
