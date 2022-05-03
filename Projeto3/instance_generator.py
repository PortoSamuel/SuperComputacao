import random
u = 0

# vai de 100 até 1000000 indo de 100 em 100
for i in range(100, 100000, 1000):
       n = i
       m = int(i/2)
        
       file = f'dna_seq_{u}.txt'  # nome do arquivo a ser gerado
       
       f = open(f"Inputs/{file}", 'w')

       seq = [str(n)+'\n',
              str(m)+'\n',
              ''.join(random.choices(['A', 'T', 'C', 'G', '-'], k=n))+'\n',
              ''.join(random.choices(['A', 'T', 'C', 'G', '-'], k=m))]

       f.writelines(seq)
       f.close()
       
       u += 1
