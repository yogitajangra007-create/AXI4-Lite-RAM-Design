# Address Map

The AXI4-Lite RAM has a memory depth of 16 words, with each word being 32 bits (4 bytes) wide. The total addressable space is 64 bytes.

| Start Address | End Address | Memory Size | Access | Description |
|---------------|-------------|-------------|--------|-------------|
| `0x00`        | `0x3F`      | 64 Bytes    | R/W    | 16 x 32-bit synchronous RAM. |

## Notes
- Access must be **32-bit word-aligned**, meaning the lower 2 bits of the address (`addr[1:0]`) should be `0b00`.
- Writing to unaligned addresses or reading from unaligned addresses will result in undefined behavior or a target error response (`SLVERR`).
- The internal decoder converts the byte address `addr[5:0]` to a 4-bit word index `addr[5:2]` to access the 16 memory locations.
