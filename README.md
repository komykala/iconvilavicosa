# ICON Jiu-Jitsu — Tournament Control v23

Interface responsiva para gerir check-in, pesagem, atletas, dois tatames e quadros de eliminação direta com avanço automático de vencedores.

## Antes de publicar
1. Faça uma exportação/backup dos dados existentes no Supabase.
2. No Supabase SQL Editor, execute `upgrade.sql` uma única vez. Este script só acrescenta colunas e índices; não elimina nem recria atletas ou combates.
3. Em `app.js`, substitua `COLOCA_AQUI_A_CHAVE_PUBLICA` pela chave pública `publishable` ou `anon` do projeto Supabase. O URL do projeto está definido. Nunca use `service_role`/`secret` no frontend.
4. Carregue `index.html`, `styles.css` e `app.js` para a raiz do repositório GitHub e faça Commit changes.
5. Em Supabase → Authentication → URL Configuration, confirme que o URL do GitHub Pages está em Redirect URLs para permitir recuperação de palavra-passe.
6. Teste com uma categoria fictícia antes de criar quadros oficiais.

## Funcionalidades
- Dashboard com contagem de inscrições, chegadas, pesagens e combates ativos.
- Check-in e pesagem em interface adaptada a telemóvel.
- Lista de atletas e importação CSV.
- Painéis dos Tatames 1 e 2 com estados por chamar, chamados e a decorrer.
- Combates manuais.
- Geração de quadro de eliminação direta a partir de atletas selecionados, com byes e rondas.
- Regras de categorias: adultos de faixa azul e roxa separados; adultos de faixa preta e castanha podem ser agrupados; faixas amarela e cinzenta agrupadas.
- Validação de escalão etário, sexo nos adultos e diferença de peso antes de criar um quadro; limite de 8 kg para adultos de faixa azul/roxa.
- Quando se confirma um vencedor, este é colocado no lugar correspondente da ronda seguinte. Byes podem avançar automaticamente.
- Recuperação de palavra-passe com redirecionamento para o URL publicado e formulário para definir a nova palavra-passe.
- Sincronização Supabase Realtime.

## Notas importantes
- A chave pública no frontend é visível por definição. A segurança depende de RLS; o esquema atual permite a qualquer utilizador autenticado editar atletas e combates. Não abra o acesso público e reveja as políticas antes do torneio.
- Para gerar quadros, o `upgrade.sql` é necessário. Não execute `schema.sql` de novo numa base de dados já em utilização.
- A geração de quadros cria combates novos; não elimina ou modifica combates existentes. Verifique nomes, categoria e atribuição de tatame antes de usar resultados oficiais.
- A importação CSV tenta atualizar atletas pelo nome completo. Reveja duplicados e homónimos manualmente.
- A sincronização exige ligação à Internet e Realtime ativo no Supabase.


## Adicionar e editar atletas
Na secção **Atletas**, use **Novo atleta** para registar um atleta no momento ou **Editar** na linha correspondente para corrigir nome, email, equipa, idade/escalão, faixa e peso. O formulário grava diretamente na tabela `athletes` do Supabase e os dados passam a aparecer no check-in, nos seletores de combates e na seleção para quadros. Também existe um atalho **Adicionar atleta no momento** no check-in. Não é necessária uma nova migração SQL para esta funcionalidade.


## Atualização de 12-10-2026 — edição móvel e chaves revistas

- No telemóvel, a gestão de atletas usa cartões pesquisáveis e o formulário abre em ecrã inteiro, com campos maiores e botões Guardar/Cancelar fixos na parte inferior.
- `proposed_brackets.json` contém 50 emparelhamentos para 100 registos de atletas após remover duas inscrições que parecem duplicados exatos.
- Os emparelhamentos são propostas: 40 registos não têm nome preenchido e surgem como `NOME POR CONFIRMAR`; confirmar identidade antes de validar os quadros.
- A importação usa prefixo `ICON-R-`. Se existirem propostas antigas `ICON-P-` ainda pendentes, pede confirmação para as substituir. Não substitui automaticamente combates chamados, em curso ou concluídos.
- A associação aos registos do Supabase privilegia o nome completo. Um email partilhado por vários familiares não é usado para escolher arbitrariamente um atleta.
- Não executar novamente `schema.sql` numa base de dados já utilizada. Publicar os ficheiros estáticos mantendo as chaves/configuração existentes.


## Controlo rápido de chamadas
Na secção **Tatames**, cada tatame tem agora um painel de controlo rápido que mostra o combate a decorrer e o seguinte chamado/em espera. É possível chamar a próxima chave e iniciar a chamada com menos passos.
Os quadros de eliminação direta já têm avanço automático de bye: quando uma luta de uma ronda tem apenas um atleta, a aplicação pode concluir esse combate como bye e avançar o atleta para a ronda seguinte. Isto aplica-se aos quadros que tenham ligações de ronda (`next_match_id`); não inventa adversários nem altera automaticamente os emparelhamentos preliminares simples.


### Controlo rápido e correção de início acidental

A área “Chamadas e combates” mostra o combate a decorrer e o seguinte por tatame, com ações principais destacadas. Se um combate for iniciado por engano, use “Desfazer início · repor como chamado”. A aplicação pede confirmação e devolve o estado a “Atletas chamados”, sem apagar atletas nem registar vencedor. A lista antiga duplicada foi ocultada nesta área para reduzir confusão.

## Controlo rápido v5
- Separadores “Próximos combates” e “Concluídos”, atualizados pelo carregamento/realtime existente.
- Nos combates a decorrer é possível escolher o vencedor ou fazer reset do início.
- Uma chamada sem resposta pode ser colocada “Em espera” e retomada mais tarde.
- Os nomes dos atletas no painel rápido abrem o percurso do atleta na categoria selecionada, com a lista de combates dessa categoria.
- Antes de usar “Colocar em espera”, executar `migration_waiting_status.sql` no Supabase SQL Editor para autorizar o novo estado `waiting`.

## Atualização v6 — navegação e percurso do atleta
- Os separadores **Próximos combates** e **Concluídos** passaram para a navegação principal, acessíveis sem entrar em Tatames ou Combates & quadros.
- Os contadores dos separadores principais acompanham os estados de combate carregados pela sincronização em tempo real.
- Clicar no nome de um atleta abre a sua consulta de percurso; quando tem mais do que uma categoria, é apresentada uma escolha clicável em vez de um prompt de texto.
- Corrigida a estrutura dos nomes clicáveis no seletor de atletas dos quadros, evitando botões interativos dentro de etiquetas de seleção.


### Exportar lista atualizada de atletas
No separador **05 — Atletas**, use **Exportar lista CSV** para descarregar todos os registos atuais guardados na aplicação, incluindo alterações de nome, email, equipa, idade, sexo, faixa, peso, chegada e pesagem. A exportação inclui todos os atletas, mesmo quando a pesquisa ou os filtros mostram apenas uma parte da lista. O ficheiro é compatível com Excel e usa ponto e vírgula como separador.

### Inscrição no próprio dia e preparação automática de chave
No formulário de novo atleta existe a opção «Após guardar, preparar automaticamente uma chave com atletas compatíveis ainda sem chave». Quando selecionada, após guardar a inscrição, a aplicação seleciona os atletas ainda sem quadro que coincidam no escalão etário e faixa; nos adultos exige sexo igual e considera também proximidade de peso. A aplicação prepara o formulário de criação do quadro e pede confirmação antes de gerar, sem alterar quadros existentes. Se não houver pelo menos dois atletas compatíveis, o atleta é guardado e a aplicação informa que é necessário associar mais atletas ou gerar o quadro manualmente.

## Versão 12 — sincronização dos dados e inferência conservadora do sexo
- Ao editar um atleta, o nome atualizado é propagado para os nomes dos participantes e vencedor em todos os combates associados por ID, para que filas, resultados e quadros apresentem os dados atualizados após recarregar.
- Para atletas sem sexo registado, a aplicação tenta inferir o sexo através de uma lista conservadora de primeiros nomes comuns em português. A inferência só é aplicada quando o campo está vazio/nulo; pode ser corrigida manualmente no formulário do atleta. Nomes ambíguos ou não reconhecidos ficam sem sexo atribuído.
- A inferência automática é uma estimativa baseada no nome, não uma confirmação da identidade ou do sexo do atleta. Verifique os registos antes de gerar combates de adultos.


### Visualização de chaves
A área de chaves mostra desde logo todos os combates existentes. Os combates ligados a um `bracket_id` usam a chave real; os restantes são agrupados provisoriamente pela categoria para que não apareça uma área vazia. A ronda é lida de `round_number` (ou assumida como ronda 1 quando não está definida). Para mostrar ligações exatas entre rondas, os combates devem ter os campos de progressão da chave corretamente preenchidos.

## Regra de agrupamento de faixas
- As faixas amarelas e cinzentas são consideradas um único grupo de emparelhamento (`Amarela/Cinzenta`) na preparação automática e na atualização da categoria da chave.
- A faixa original de cada atleta continua guardada no registo; não são alterados os dados originais.
- Idade/escalão e diferença de peso continuam a ser critérios de compatibilidade.

## Regra de agrupamento de faixas
- As faixas amarelas e cinzentas são consideradas um único grupo de emparelhamento (`Amarela/Cinzenta`) na preparação automática e na atualização da categoria da chave.
- A faixa original de cada atleta continua guardada no registo; não são alterados os dados originais.
- Idade/escalão e diferença de peso continuam a ser critérios de compatibilidade.


## Versão 24 — interface e mesa de pontos

### Melhorias visuais
- Navegação mais legível, contraste e hierarquia visual reforçados, cartões e tabelas com maior separação.
- Referências de combate passam a mostrar categoria, fase/ronda e tatame; o código técnico fica apenas como referência secundária quando disponível.

### Mesa de pontos em ecrã inteiro
- Nova secção **08 · Mesa de pontos**.
- Selecionar o combate; iniciar, pausar e reiniciar o temporizador; duração configurável.
- Pontuação por atleta (+2, +3, +4 e correção de -1), vantagens e penalizações.
- Escolha manual do vencedor e gravação na cloud; em quadros ligados, o vencedor avança para a ronda seguinte.
- O temporizador funciona no dispositivo da mesa e não sincroniza o relógio entre dispositivos. A pontuação só é persistida quando se guarda o resultado.

### Migração necessária para a pontuação
Antes de utilizar o botão **Guardar resultado final**, executar `migration_scoreboard_v24.sql` no SQL Editor do Supabase. A migração apenas acrescenta colunas à tabela `matches`; não elimina nem reinicia dados existentes.

### Publicação
Substituir `index.html`, `styles.css` e `app.js` no repositório GitHub Pages pelos ficheiros desta versão. Manter o restante conteúdo e a configuração Supabase existente. A aplicação não foi publicada automaticamente.


## Versão 25 — mesa de pontos para transmissão
- O marcador em ecrã inteiro foi redesenhado segundo a referência visual fornecida: duas faixas horizontais por atleta, três cartões grandes para pontos/vantagens/penalizações e relógio grande na zona inferior.
- Controlos rápidos para adicionar pontos, vantagens e penalizações, iniciar/pausar/reiniciar o tempo, trocar cores e emitir um alerta sonoro.
- A seleção de vencedor e gravação final continuam na área inferior do marcador.
- O botão de trocar cores altera a apresentação visual dos lados no ecrã; não altera os atletas nem a pontuação registada.


## Versão 26 — correção de ecrã inteiro
- Corrigido o dimensionamento em ecrã inteiro com regras explícitas para ocupar 100% da largura e altura do ecrã.
- Atualizada a versão da folha de estilos e do JavaScript na URL para forçar a renovação da cache do navegador.
- Reforçada a apresentação das duas faixas de atletas, cartões de pontuação e cronómetro no modo de ecrã inteiro.


## Versão 27 — fim automático de combate
- Em ecrã inteiro, a secção manual de seleção de vencedor/registo de resultado fica oculta.
- Quando o cronómetro chega a zero, é emitido automaticamente um sinal sonoro, a pontuação é usada para determinar o vencedor (pontos; em igualdade, vantagens; em nova igualdade, menos penalizações) e o resultado é guardado.
- O vencedor avança para a ronda seguinte quando a chave tem ligação configurada.
- Dois minutos após o fim, o próximo combate pronto é carregado no marcador, mas o cronómetro não inicia sozinho: a mesa deve confirmar que os atletas estão prontos e carregar em Iniciar.
- Se pontos, vantagens e penalizações ficarem exatamente iguais, o resultado não é decidido automaticamente; a mesa tem de aplicar as regras da competição e confirmar o vencedor.
- O navegador precisa de permitir áudio. O sinal é gerado localmente no momento em que o cronómetro termina.


## Versão 28 — categoria e fase explícitas no marcador
- Corrigido o texto do marcador: a categoria é apresentada separadamente da fase da chave.
- A categoria usa o nome da categoria registada; quando não existe nome útil, tenta compor a informação com o escalão etário e a faixa dos atletas.
- A fase é apresentada como Final, Meia-final, Quartos de final, Oitavos de final ou ronda correspondente.
- Removido um ID HTML duplicado que impedia atualizar o texto visível no rodapé do marcador.


## Versão 29 — correção do carregamento automático seguinte
- O agendamento dos 120 segundos é agora independente da atualização da interface e da cache local de combates.
- Após guardar automaticamente o resultado, mantém o combate terminado visível durante os dois minutos.
- No fim do intervalo, consulta novamente os combates diretamente no Supabase e carrega o primeiro combate elegível com os dois atletas atribuídos.
- Tenta preservar o modo de ecrã inteiro e deixa o relógio parado para a mesa iniciar quando estiver pronta.


## Versão 30 — etiquetas reais de categoria e fase
- Removidos os textos estáticos de exemplo “CATEGORIA · RONDA”.
- A etiqueta de categoria passa a ser construída a partir da categoria guardada e, quando genérica, da faixa e do escalão etário dos atletas.
- A etiqueta da fase é calculada a partir da ronda e dos combates da mesma chave/categoria; quando não há dados de ronda, apresenta “Combate” em vez de “Ronda”.
- Atualizadas as versões CSS/JS para invalidar a cache do navegador.
