from riscv_assembler.convert import AssemblyConverter as AC


def remove_2first_chars(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    new_lines = [line[2:] if len(line) > 2 else '\n' for line in lines]

    with open('new_' + filename, 'w') as file:
        file.writelines(new_lines)
        
        
# instantiate object, by default outputs to a file in nibbles, not in hexademicals
convert = AC(output_mode = 'f', nibble_mode = False, hex_mode = True)

# Convert a whole .s file to text file
convert("main.s", "input_text.txt")



# Call the function with the name of your file
remove_2first_chars("input_text.txt")
