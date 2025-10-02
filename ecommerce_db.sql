create database ecommerce_db;

use ecommerce_db;

/* ----- Criação das tabelas ----- */

create table if not exists Cliente (
	id int primary key auto_increment,
    pnome varchar(60) not null, 
    sobrenome varchar(60) not null, 
    email varchar(255) not null unique,
    senha varchar(256) not null, 
    telefone varchar(20) not null
);

create table if not exists Endereco (
	id int primary key auto_increment,
    cliente_id int not null,
    rua varchar(100) not null,
    numero varchar(10) not null,
    bairro varchar(60) not null, 
    cidade varchar(60) not null,
    estado char(2) not null,
    cep char(8) not null,
    constraint fk_cliente_endereco foreign key (cliente_id) references Cliente(id) on update cascade on delete cascade
);

create table if not exists Pedido (
	id int primary key auto_increment,
    cliente_id int not null,
    endereco_id int not null,
    data_pedido datetime not null default now(), 
    valor_total decimal(10,2) not null,
    status_pedido varchar(20) not null default("Aguardando Pagamento"),
    constraint fk_cliente_pedido foreign key (cliente_id) references Cliente(id) on update cascade on delete restrict,
    constraint fk_endereco_pedido foreign key (endereco_id) references Endereco(id) on update cascade on delete restrict
);

create table if not exists Pagamento (
	id int primary key auto_increment,
    pedido_id int not null unique,
    data_pagamento datetime not null default now(), 
    status_pagamento varchar(20) not null,
    constraint fk_pedido_pagamento foreign key (pedido_id) references Pedido(id) on update cascade on delete cascade
);

create table if not exists Pix (
	pagamento_id int primary key not null,
    chave_pix varchar(120) not null,
    constraint fk_pagamento_pix foreign key (pagamento_id) references Pagamento(id) on update cascade on delete cascade
);

create table if not exists Boleto (
	pagamento_id int primary key not null,
    codigo varchar(60) not null unique,
	data_vencimento date not null,
    constraint fk_pagamento_boleto foreign key (pagamento_id) references Pagamento(id) on update cascade on delete cascade
);

create table if not exists Cartao (
	pagamento_id int primary key not null,
    numero varchar(20) not null,
	validade char(5) not null, -- Padrão: '12-29' (5 caracteres)
    cvc varchar(4) not null,
    constraint fk_pagamento_cartao foreign key (pagamento_id) references Pagamento(id) on update cascade on delete cascade
);

create table if not exists Categoria (
	id int primary key auto_increment,
	nome varchar(100) not null unique,
	descricao varchar(500)
);

create table if not exists Produto (
	id int primary key auto_increment,
    categoria_id int not null,
    nome varchar(100) not null unique,
    descricao varchar(500),
    imagem_url varchar(255) not null,
	preco decimal(10,2) not null,
    tamanho varchar(10),
	qtd_estoque int not null,
    constraint fk_categoria_produto foreign key (categoria_id) references Categoria(id) on update cascade on delete restrict
);

create table if not exists ItemPedido (
	pedido_id int not null,
    produto_id int not null,
	quantidade int not null,
    primary key (pedido_id, produto_id),
    constraint fk_pedido_item foreign key (pedido_id) references Pedido(id) on update cascade on delete cascade,
    constraint fk_produto_item foreign key (produto_id) references Produto(id) on update cascade on delete restrict
);

/* ----- Inserção de dados ----- */

insert into Cliente (pnome, sobrenome, email, senha, telefone) values 
("Memphis", "Depay", "m.depay@gmail.com", SHA2(concat('salt', 'minhaSenha'), 256), "61984378860"),
("Cassio", "Ramos", "cassio.r@gmail.com", SHA2(concat('salt', 'senhaMuitoSegura'), 256), "61993664519");

insert into Endereco (cliente_id, rua, numero, bairro, cidade, estado, cep) values 
(1, "Rua 2", "92", "SHVP", "Brasília", "DF", "72115025"),
(1, "CNB 14", "54", "Taguatinga Norte", "Brasília", "DF", "72125050"),
(2, "QNE 5", "7", "Taguatinga Norte", "Brasília", "DF", "72110027");

insert into Pedido (cliente_id, endereco_id, valor_total) values 
(1, 1, 139.90),
(1, 2, 239.80),
(2, 3, 299.70);

insert into Pagamento (pedido_id, status_pagamento) values 
(1, "Aprovado"),
(2, "Recusado");

insert into Pix (pagamento_id, chave_pix) values 
(1, "07289851102");

insert into Cartao (pagamento_id, numero, validade, cvc) values 
(2, "50505050101010", "12-30", "134");

insert into Categoria (nome, descricao) values 
("Casacos", "Roupas para usar nessa temporada de frio!"),
("Camisetas", "Camisetas básicas, oversized e slim");

insert into Produto (categoria_id, nome, descricao, imagem_url, preco, tamanho, qtd_estoque) values 
(1, "Moletom Canguru", "Lindo moletom com capuz e bolso canguru", "https://img.ltwebstatic.com/v4/j/spmp/2025/08/18/e6/1755515893612011cef33a8a67e4fadb9d59353436_thumbnail_560x.webp", 139.90, "M", 37),
(2, "Camiseta Slim", "Camiseta canelada slim", "https://www.insiderstore.com.br/cdn/shop/files/TechT-ShirtHeavySlim_Preta_06_ddf53303-68c7-430f-9714-6526ffc20c36.jpg?v=1758647729&width=1206", 99.90, "P", 52);

insert into ItemPedido (pedido_id, produto_id, quantidade) values 
(1, 1, 1),
(2, 1, 1),
(2, 2, 1),
(3, 2, 3);

/* ----- Consultas ----- */

-- Retornar o nome dos clientes e o CEP de seus endereços
select C.pnome, C.sobrenome, E.cep from Cliente C 
left join Endereco E on C.id = E.cliente_id;

-- Retornar o nome dos clientes que já fizeram algum pedido e a quantidade de pedidos de cada um em ordem decrescente
select C.pnome, C.sobrenome, count(P.id) as qtd_pedidos from Cliente C 
join Pedido P on C.id = P.cliente_id
group by C.id
order by qtd_pedidos desc;

-- Retornar pedidos que ainda não tem pagamento registrado
select Pe.id, Pe.cliente_id, Pe.endereco_id, Pe.data_pedido, Pe.valor_total, Pe.status_pedido from Pedido Pe
left join Pagamento Pa on Pe.id = Pa.pedido_id
where Pa.id is null;

-- Retornar o nome do cliente, id dos pedidos dele, nome e preço dos produtos de cada pedido
select C.pnome as cliente_nome, Pe.id as id_pedido, Pr.nome as produto_nome, Pr.preco from Cliente C
join Pedido Pe on C.id = Pe.cliente_id
join ItemPedido I on Pe.id = I.pedido_id
join Produto Pr on I.produto_id = Pr.id
order by Pe.id;

/* ----- Atualização dos dados ----- */

-- Atualizando status de pedidos que têm registro de pagamento com status Aprovado
update Pedido Pe
left join Pagamento Pa on Pe.id = Pa.pedido_id
set Pe.status_pedido = 'Enviado'
where Pa.id is not null and Pa.status_pagamento = 'Aprovado';