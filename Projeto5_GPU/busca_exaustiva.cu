#include <chrono>
#include <vector>
#include <iostream>
#include <thrust/transform.h>
#include <thrust/functional.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
using namespace std;

struct nucleotidio
{
    int id;
    char base;
};

struct mat_ele
{
    int i = -1, j = -1, val = 0;
};

struct result
{
    int score = 0;
    thrust::device_vector<nucleotidio> subseq_a;
    thrust::device_vector<nucleotidio> subseq_b;
};

// Function to create all the power set
vector<vector<nucleotidio>> createPowerSet(vector<nucleotidio> set, int set_size)
{
    vector<vector<nucleotidio>> power_set_list;
    vector<nucleotidio> subseq;

    // Set_size of power set of a set with set_size
    // n is (2^n-1)
    int pow_set_size = pow(2, set_size);
    int counter, j;

    // Run from counter 000..0 to 111..1
    for (counter = 0; counter < pow_set_size; counter++)
    {
        for (j = 0; j < set_size; j++)
        {
            // Check if jth bit in the counter is set
            // If set then save jth element from set
            if (counter & (1 << j))
            {
                nucleotidio n;
                n.id = j;
                n.base = set[j].base;
                subseq.push_back(n);
            }
        }

        if (subseq.size() > 0)
        {
            // verify if the elements in the subsequence are subseq of the original set
            bool is_subseq = true;
            int size = subseq.size();

            for (int i = 0; i < size - 1; i++)
            {
                if (subseq[i + 1].id == subseq[i].id + 1)
                {
                    is_subseq = true;
                }
                else
                {
                    is_subseq = false;
                    break;
                }
            }

            if (is_subseq)
            {
                power_set_list.push_back(subseq);
            }

            subseq.clear();
        }
    }

    return power_set_list;
}

int char_score(char a, char b)
{
    if (a == b && b != '-')
    {
        return 2;
    }
    else
    {
        return -1;
    }
}

// Fun????o que calcula o score de duas subsequencias de mesmo tamanho paralelizando na GPU
template <typename T>
struct w
{
    int value;
    typedef int result_type;
    typedef T first_argument_type;
    typedef T second_argument_type;

    __host__ __device__
        T
        operator()(const T &x, const T &y) const
    {
        value = 0;

        if (x.base == y.base && y.base != '-')
        {
            value += 2;
        }
        else
        {
            value -= 1;
        }

        return value;
    }
};

// Algoritmo de smith-waterman para calcular o score de subsequencias com diferentes tamanhos
// int Smith_Waterman(vector<nucleotidio> seq_a, vector<nucleotidio> seq_b)
// {
//     int n = seq_a.size();
//     int m = seq_b.size();

//     vector<vector<mat_ele>> H(n + 1, vector<mat_ele>(m + 1));

//     for (int i = 0; i < n + 1; i++)
//     {
//         for (int j = 0; j < m + 1; j++)
//         {
//             mat_ele item;

//             if (j == 0 || i == 0)
//             {
//                 H[i][j] = item;
//             }
//             else
//             {

//                 int diagonal = H[i - 1][j - 1].val + char_score(seq_a[i - 1].base, seq_b[j - 1].base);
//                 int delecao = H[i - 1][j].val - 1;
//                 int insercao = H[i][j - 1].val - 1;

//                 if (max({0, diagonal, delecao, insercao}) == diagonal)
//                 {
//                     item.i = i - 1;
//                     item.j = j - 1;
//                 }
//                 else if (max({0, diagonal, delecao, insercao}) == delecao)
//                 {
//                     item.i = i - 1;
//                     item.j = j;
//                 }
//                 else if (max({0, diagonal, delecao, insercao}) == insercao)
//                 {
//                     item.i = i;
//                     item.j = j - 1;
//                 }

//                 item.val = max({0, diagonal, delecao, insercao});

//                 H[i][j] = item;
//             }
//         }
//     }

//     mat_ele max;

//     for (auto &el1 : H)
//     {
//         for (auto &el2 : el1)
//         {
//             if (el2.val > max.val)
//             {
//                 max = el2;
//             }
//         }
//     }

//     return max.val;
// }

int main()
{
    int n = 0;
    int m = 0;

    srand(24); // "Random" Seed

    cin >> n >> m;

    nucleotidio element;
    result resultado;

    // Sequencias A e B
    vector<nucleotidio> a;
    vector<nucleotidio> b;

    // Listas com todos os subconjuntos de A e B
    vector<vector<nucleotidio>> powerset_a;
    vector<vector<nucleotidio>> powerset_b;

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
    // Para que as subsequencias de tamanho k n??o sejam maior que a sequencia a
    if (m > n)
    {
        int aux = n;
        vector<nucleotidio> temp = a;

        a = b;
        b = temp;

        n = m;
        m = aux;
    }

    // Enviando para a GPU as sequencias A e B
    thrust::device_vector<nucleotidio> gpu_a(a);
    thrust::device_vector<nucleotidio> gpu_b(b);

    // Gera todos os subconjuntos de A e B e armazena em powerset_a e powerset_b
    powerset_a = createPowerSet(a, n);
    powerset_b = createPowerSet(b, m);

    // Enviando para a GPU os powersets de A e B
    thrust::device_vector<thrust::device_vector<nucleotidio>> gpu_powerset_a(powerset_a);
    thrust::device_vector<thrust::device_vector<nucleotidio>> gpu_powerset_b(powerset_b);

    // Calcula o score de todas as subsequencias de A e B
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            int temp_score = 0;

            if (gpu_powerset_a[i].size() == gpu_powerset_b[j].size())
            {
                thrust::device_vector<nucleotidio> res(gpu_powerset_b[j].size());
                thrust::transform(gpu_powerset_b[j].begin(), gpu_powerset_b[j].end(), gpu_powerset_a[i].end(), res.begin(), w());

                temp_score = thrust::reduce(res.begin(), res.end(), 0);
            }
            else
            {
                // temp_score = Smith_Waterman(gpu_powerset_a[i], gpu_powerset_b[j]);
            }

            // Verifica se o temp_score ?? maior que o score do resultado
            if (temp_score > resultado.score)
            {
                resultado.score = temp_score;
                resultado.subseq_a = gpu_powerset_a[i];
                resultado.subseq_b = gpu_powerset_b[j];
            }
        }
    }

    // Imprime o resultado e as subsequencias
    cout << "subsequencia A: ";
    for (int i = 0; i < resultado.subseq_a.size(); i++)
    {
        cout << resultado.subseq_a[i].base;
    }
    cout << endl;

    cout << "subsequencia B: ";
    for (int i = 0; i < resultado.subseq_b.size(); i++)
    {
        cout << resultado.subseq_b[i].base;
    }
    cout << endl;

    cout << "Score: " << resultado.score << endl;

    return 0;
}
