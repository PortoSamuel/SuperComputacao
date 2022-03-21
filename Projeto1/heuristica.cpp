#include <iostream>
#include <vector>
#include <stdlib.h>
#include <algorithm>
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

int w(char a, char b)
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

int main()
{
    int n = 0;
    int m = 0;

    cin >> n >> m;

    nucleotidio element;

    vector<nucleotidio> seq_n;
    vector<nucleotidio> seq_m;

    vector<int> n_i;
    vector<int> m_j;

    vector<vector<mat_ele>> H(n + 1, vector<mat_ele>(m + 1));

    for (int i = 0; i < n; i++)
    {
        element.id = i;
        cin >> element.base;

        seq_n.push_back(element);
    }

    for (int i = 0; i < m; i++)
    {
        element.id = i;
        cin >> element.base;

        seq_m.push_back(element);
    }

    for (int i = 0; i < n + 1; i++)
    {
        for (int j = 0; j < m + 1; j++)
        {
            mat_ele item;

            if (j == 0 || i == 0)
            {

                H[i][j] = item;
            }
            else
            {

                int diagonal = H[i - 1][j - 1].val + w(seq_n[i - 1].base, seq_m[j - 1].base);
                int delecao = H[i - 1][j].val - 1;
                int insercao = H[i][j - 1].val - 1;

                if (max({0, diagonal, delecao, insercao}) == diagonal)
                {
                    item.i = i - 1;
                    item.j = j - 1;
                }
                else if (max({0, diagonal, delecao, insercao}) == delecao)
                {
                    item.i = i - 1;
                    item.j = j;
                }
                else if (max({0, diagonal, delecao, insercao}) == insercao)
                {
                    item.i = i;
                    item.j = j - 1;
                }

                item.val = max({0, diagonal, delecao, insercao});

                H[i][j] = item;
            }
        }
    }

    mat_ele max;

    for (auto &el1 : H)
    {
        for (auto &el2 : el1)
        {
            if (el2.val > 9)
            {
                cout << " " << el2.val;
            }
            else
            {
                cout << " " << el2.val << " ";
            }
            if (el2.val > max.val)
            {
                max = el2;
            }
        }

        cout << endl;
    }

    cout << endl << max.val;

    while (max.i >= 0 && max.j >= 0)
    {
        n_i.push_back(max.i);
        m_j.push_back(max.j);

        max = H[max.i][max.j];

        cout << " --> " << max.val;
    }

    cout << endl << endl;

    for (auto &id : n_i)
    {
        cout << seq_n[id].base;
    }

    cout << endl;

    for (long unsigned int i = 0; i < n_i.size(); i++)
    {
        if (seq_n[i].base == seq_m[i].base)
        {
            cout << '*';
        }else{
            cout << '|';
        }
    }

    cout << endl;

    for (auto &id : m_j)
    {
        cout << seq_m[id].base;
    }

    cout << endl;

    return 0;
}