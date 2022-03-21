import random

n = 3  # tamanho da primeira sequência
m = 4  # tamanho da segunda sequência

file = 'dna_seq.txt'  # nome do arquivo a ser gerado
f = open(f"./Projeto1/{file}", 'w')

seq = [str(n)+'\n',
       str(m)+'\n',
       ''.join(random.choices(['A', 'T', 'C', 'G', '-'], k=n))+'\n',
       ''.join(random.choices(['A', 'T', 'C', 'G', '-'], k=m))]

f.writelines(seq)
f.close()

print(''.join(seq))
