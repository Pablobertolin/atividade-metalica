CREATE DATABASE IF NOT EXISTS industria_metalica_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE industria_metalica_db;

CREATE TABLE IF NOT EXISTS usuarios (
  id INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  senha VARCHAR(255) NOT NULL,
  ativo TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS produtos (
  id INT NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nome VARCHAR(150) NOT NULL,
  fabricante VARCHAR(100) NOT NULL DEFAULT 'Geral',
  preco DECIMAL(10,2) NOT NULL,
  estoque_atual INT NOT NULL DEFAULT 0,
  estoque_minimo INT NOT NULL DEFAULT 0,
  ativo TINYINT NOT NULL DEFAULT 1,
  peso DECIMAL(10,3) NOT NULL DEFAULT 0,
  categoria VARCHAR(100) NOT NULL,
  unidade VARCHAR(20) NOT NULL DEFAULT 'un',
  material_fabricacao VARCHAR(100) NULL,
  espessura VARCHAR(50) NULL,
  dimensoes VARCHAR(100) NULL,
  acabamento VARCHAR(100) NULL,
  aplicacao VARCHAR(255) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_produtos_codigo (codigo),
  KEY idx_produtos_categoria (categoria)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fornecedores (
  id INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  cnpj VARCHAR(18) NULL,
  telefone VARCHAR(20) NULL,
  email VARCHAR(100) NULL,
  cidade VARCHAR(100) NULL,
  ativo TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fornecedores_cnpj (cnpj)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS materias_primas (
  id INT NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nome VARCHAR(150) NOT NULL,
  unidade VARCHAR(20) NOT NULL DEFAULT 'kg',
  estoque_atual DECIMAL(10,3) NOT NULL DEFAULT 0,
  estoque_minimo DECIMAL(10,3) NOT NULL DEFAULT 0,
  fornecedor_id INT NULL,
  ativo TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_materias_primas_codigo (codigo),
  KEY idx_materias_primas_fornecedor (fornecedor_id),
  CONSTRAINT fk_materias_primas_fornecedor
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ordens_producao (
  id INT NOT NULL AUTO_INCREMENT,
  numero_ordem VARCHAR(50) NOT NULL,
  produtos_id INT NOT NULL,
  quantidade INT NOT NULL DEFAULT 0,
  data_inicio DATE NOT NULL,
  data_fim DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'aberta',
  observacao TEXT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ordens_numero (numero_ordem),
  KEY idx_ordens_produto (produtos_id),
  CONSTRAINT fk_ordens_produto
    FOREIGN KEY (produtos_id) REFERENCES produtos (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movimentacoes (
  id INT NOT NULL AUTO_INCREMENT,
  tipo TINYINT NOT NULL COMMENT '1 = entrada, 2 = saída',
  data DATE NOT NULL,
  quantidade INT NOT NULL,
  saldo_anterior INT NOT NULL,
  usuarios_id INT NOT NULL,
  produtos_id INT NOT NULL,
  PRIMARY KEY (id),
  KEY idx_movimentacoes_usuario (usuarios_id),
  KEY idx_movimentacoes_produto (produtos_id),
  CONSTRAINT fk_movimentacoes_usuario
    FOREIGN KEY (usuarios_id) REFERENCES usuarios (id),
  CONSTRAINT fk_movimentacoes_produto
    FOREIGN KEY (produtos_id) REFERENCES produtos (id)
) ENGINE=InnoDB;

INSERT INTO usuarios (nome, email, senha, ativo)
VALUES ('Administrador', 'admin@metal.com', 'admin123', 1)
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

INSERT INTO fornecedores (nome, cnpj, telefone, email, cidade, ativo)
VALUES
  ('Metal Sul Fornecedores', '12.345.678/0001-90', '(11) 3333-4444', 'contato@metalsul.com', 'São Paulo', 1),
  ('Aço Forte Materiais', '98.765.432/0001-10', '(11) 5555-6666', 'vendas@acoforte.com', 'Campinas', 1)
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

INSERT INTO materias_primas (codigo, nome, unidade, estoque_atual, estoque_minimo, fornecedor_id, ativo)
VALUES
  ('MP-001', 'Aço carbono', 'kg', 250.000, 50.000, 1, 1),
  ('MP-002', 'Chapa galvanizada', 'kg', 180.000, 40.000, 2, 1)
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

INSERT INTO ordens_producao (numero_ordem, produtos_id, quantidade, data_inicio, data_fim, status, observacao)
VALUES
  ('OP-2026-001', 1, 10, '2026-10-01', '2026-10-03', 'em_andamento', 'Produção de chapas para estoque'),
  ('OP-2026-002', 2, 5, '2026-10-02', NULL, 'aberta', 'Pedido especial para linha de montagem')
ON DUPLICATE KEY UPDATE quantidade = VALUES(quantidade);

INSERT INTO produtos
  (codigo, nome, fabricante, preco, estoque_atual, estoque_minimo, ativo, peso, categoria, unidade, material_fabricacao, espessura, dimensoes, acabamento, aplicacao)
VALUES
  ('CH-001', 'Chapa galvanizada lisa', 'Aço Forte', 189.90, 20, 5, 1, 18.500, 'Chapas', 'un', 'Aço carbono galvanizado', '0,50 mm', '1,20 x 2,00 m', 'Galvanizado', 'Calhas, rufos e coberturas'),
  ('CH-002', 'Chapa xadrez de aço carbono', 'Aço Forte', 329.90, 12, 3, 1, 32.000, 'Chapas', 'un', 'Aço carbono', '3,00 mm', '1,20 x 2,00 m', 'Xadrez', 'Pisos e plataformas antiderrapantes'),
  ('TR-001', 'Treliça de aço TG 8', 'MetalSul', 48.50, 60, 15, 1, 4.200, 'Treliças', 'barra', 'Aço CA-60', '8 cm', '6 m', 'Nervurado', 'Armação de vigotas para lajes'),
  ('PF-001', 'Perfil U enrijecido', 'MetalSul', 96.00, 25, 6, 1, 8.400, 'Perfis metálicos', 'barra', 'Aço carbono', '2,65 mm', '100 x 50 x 3.000 mm', 'Natural', 'Estruturas metálicas e coberturas'),
  ('BT-001', 'Tubo metalon quadrado', 'Ferro & Cia', 74.90, 40, 10, 1, 5.600, 'Barras e tubos', 'barra', 'Aço carbono', '1,50 mm', '30 x 30 x 6.000 mm', 'Preto', 'Serralheria e estruturas leves')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  fabricante = VALUES(fabricante),
  preco = VALUES(preco),
  categoria = VALUES(categoria),
  material_fabricacao = VALUES(material_fabricacao),
  espessura = VALUES(espessura),
  dimensoes = VALUES(dimensoes),
  acabamento = VALUES(acabamento),
  aplicacao = VALUES(aplicacao);