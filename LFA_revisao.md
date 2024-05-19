# Linguagens Regulares

- **Qual a importância do estudo de linguagens regulares?**

  Apesar de sua baixa expressividade, linguagens regulares possuem fácil implementação e alta eficiência, tornando-as úteis para diversas aplicações reais.

- **Quais são os tipos de formalismos usados para reconhecer/gerar linguagens regulares?**

  Autômatos finitos (reconhecedor, operacional), expressões regulares (gerador, denotacional) e gramáticas regulares (gerador, axiomático).

- **Descreva, com suas palavras, as diferenças entre autômatos finitos determinísticos (AFD), não determinísticos (AFN) e com movimentos vazios (AFNe) em relação à:**

  - **Dificuldade de construção**

    Apesar de haver exceções, geralmente, quanto maior o nível de abstração do autômato, mais fácil é sua implementação, ou seja, AFNe's são normalmente mais simples de serem construídos do que AFN's que, por sua vez, são mais simples que AFD's. Isso se deve ao fato de que muitas ideias ou regras de uma linguagem são mais fácilmente representadas com a possibilidade de, dado um símbolo, ter múltiplos possíveis caminhos (particular a AFN's e AFNe's) ou mudar de estado sem o consumo de símbolos (particular a AFNe's).

  - **Complexidade de implementação**

    A implementação de AFD's possui a menor complexidade. Diferente de AFN's e AFNe's, a função programa de um AFD possui apenas um estado de destino possível dado um estado de origem e um símbolo. O não determinismo obriga a lidar com múltiplos possíveis próximos passos.

  - **Condição de aceite/rejeição de palavras**

    Um autômato determinístico aceita uma palavra caso todos os símbolos tenham sido lidos e a execução tenha terminado em um estado final, sendo rejeitada caso contrário. No caso de não determinismo, pelo menos uma das ramificações criadas pela função programa deve satisfazer as condições acima.
