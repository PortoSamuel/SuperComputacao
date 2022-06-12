#include <omp.h>
#include <chrono>
#include <vector>
#include <iostream>
#include <stdlib.h>
#include <algorithm>
using namespace std;

struct nucleotidio
{
    int id;
    char base;
};

struct result
{
    int score = 0;
    vector<nucleotidio> subseq_a;
};

int w(char a, char b)
{
    if (a == b && b != '-')
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int main()
{
    int n = 0;
    int m = 0;
    int k = 0;

    srand(24); // "Random" Seed

    cin >> n >> m;

    nucleotidio element;
    result resultado;

    vector<nucleotidio> a;
    vector<nucleotidio> b;

    vector<nucleotidio> sa;
    vector<nucleotidio> sb;
    vector<int> list_i;

    vector<vector<nucleotidio>> list_sa;

    // Captura os elementos da primeira sequencia
    for (int i = 0; i < n; i++)
    {
        element.id = i;
        cin >> element.base;

        a.push_back(element);
    }

    // Captura os elementos da segunda sequencia
    for (int i = 0; i < m; i++)
    {
        element.id = i;
        cin >> element.base;

        b.push_back(element);
    }

    // Garantindo que a sequencia A seja a maior que a B
    // Para que as subsequencias de tamanho k não sejam maior que a sequencia a

    // Marcando o start time
    auto start = chrono::high_resolution_clock::now();

#pragma omp parallel
    {
#pragma omp single
        if (m > n)
        {
            int aux = n;
            vector<nucleotidio> temp = a;

            a = b;
            b = temp;

            n = m;
            m = aux;
        }
    }

    // Gera o número aleatório j que será o índice inicial da sequência sb
    int j = rand() % m;
    // cout << "j: "<< j << endl;

    // Gera o número aleatório k que será o tamanho da sequência sb
    // k tem que ser limitado ao tamanho de m
    k = rand() % (m - j) + 1;
    // cout << "k: " << k << endl;

    // Gera a sequência sb
    cout << "sb: [";
    for (int i = j; i < j + k; i++)
    {
        sb.push_back(b[i]);
        cout << b[i].base;
    }
    cout << "]" << endl;

    // Gera o número aleatório p que será o tamanho de list_sa
    int p = rand() % (n - k) + 1;
    // cout << "p: " << p << endl;

    // Gera os p índices i aleatórios que serão os índices iniciais das subsequências sa
    for (int i = 0; i < p; i++)
    {
        list_i.push_back(rand() % n + 1);
    }

    // Gera p subsequências sa a adiciona elas na lista de subsequências list_sa
    for (auto &el : list_i)
    {
        for (int j = el; j < el + k; j++)
        {
            sa.push_back(a[j]);
        }

        list_sa.push_back(sa);
        sa.clear();
    }

    // Print dos elementos da lista de subsequências list_sa
    int cont = 0;
    cout << "list_sa: [";
    for (auto &el : list_sa)
    {
        for (auto &el2 : el)
        {
            cout << el2.base;
        }

        if (cont < p - 1)
        {
            cout << ", ";
        }

        cont++;
    }
    cout << "]" << endl;

    // Calcula o score da sequência sb para cada elemento da lista de subsequências list_sa
    int score = 0;

#pragma omp parallel for
    for (auto &el : list_sa)
    {
        for (int i = 0; i < k; i++)
        {
            score += w(sb[i].base, el[i].base);
        }

        // Verifica se o score é maior que o score do resultado
        if (score > resultado.score)
        {
            resultado.score = score;
            resultado.subseq_a = el;
        }
    }

    // Marcando o end time
    auto end = chrono::high_resolution_clock::now();

    // Print do score do resultado
    cout << "melhor sa: [";
    for (auto &el : resultado.subseq_a)
    {
        cout << el.base;
    }

    cout << "]" << endl;

    cout << "score: " << resultado.score << endl;

    // Print do tempo de execução
    cout << "tempo paralelo: " << chrono::duration_cast<chrono::milliseconds>(end - start).count() << "ms" << endl;

    return 0;
}