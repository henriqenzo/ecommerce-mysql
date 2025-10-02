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
