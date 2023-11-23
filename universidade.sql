USE universidade;


-- tabela de áreas
CREATE TABLE Area (
    AreaID INT PRIMARY KEY,
    NomeArea VARCHAR(50) NOT NULL
);

-- tabela de cursos
CREATE TABLE Curso (
    CursoID INT PRIMARY KEY,
    NomeCurso VARCHAR(50) NOT NULL,
    AreaID INT,
    FOREIGN KEY (AreaID) REFERENCES Area(AreaID)
);

-- tabela de alunos
CREATE TABLE Aluno (
    AlunoID INT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL,
    Sobrenome VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- tabela de matrículas
CREATE TABLE Matricula (
    MatriculaID INT PRIMARY KEY,
    AlunoID INT,
    CursoID INT,
    DataMatricula DATE,
    FOREIGN KEY (AlunoID) REFERENCES Aluno(AlunoID),
    FOREIGN KEY (CursoID) REFERENCES Curso(CursoID)
);

-- Stored Procedure para colocar um novo curso
DELIMITER //
CREATE PROCEDURE InserirCurso(
    IN p_NomeCurso VARCHAR(50),
    IN p_NomeArea VARCHAR(50)
)
BEGIN
    DECLARE area_id INT;
    
    -- Verifica se a área já existe
    SELECT AreaID INTO area_id FROM Area WHERE NomeArea = p_NomeArea;
    
    -- Se não existir, insere a área
    IF area_id IS NULL THEN
        INSERT INTO Area (NomeArea) VALUES (p_NomeArea);
        SET area_id = LAST_INSERT_ID();
    END IF;
    
    -- Insere o curso
    INSERT INTO Curso (NomeCurso, AreaID) VALUES (p_NomeCurso, area_id);
END //
DELIMITER ;


-- Procedure para realizar a matrícula de um aluno em um curso
DELIMITER //
CREATE PROCEDURE MatricularAluno(
    IN p_NomeAluno VARCHAR(50),
    IN p_SobrenomeAluno VARCHAR(50),
    IN p_EmailAluno VARCHAR(100),
    IN p_NomeCurso VARCHAR(50),
    IN p_NomeArea VARCHAR(50)
)
BEGIN
    DECLARE aluno_id INT;
    DECLARE curso_id INT;
    
    -- Verifica se o aluno já está matriculado
    SELECT AlunoID INTO aluno_id FROM Aluno WHERE Email = p_EmailAluno;
    
    IF aluno_id IS NULL THEN
        -- Se o aluno não existe, insere o aluno
        INSERT INTO Aluno (Nome, Sobrenome, Email) VALUES (p_NomeAluno, p_SobrenomeAluno, p_EmailAluno);
        SET aluno_id = LAST_INSERT_ID();
    ELSE
        -- Verifica se o aluno já está matriculado no curso
        SELECT CursoID INTO curso_id
        FROM Matricula
        WHERE AlunoID = aluno_id AND CursoID = ObterIDCurso(p_NomeCurso, p_NomeArea);
        
        IF curso_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Aluno já matriculado no curso.';
        END IF;
    END IF;
    
    -- Obtém o ID do curso
    SET curso_id = ObterIDCurso(p_NomeCurso, p_NomeArea);
    
    -- Insere a matrícula
    INSERT INTO Matricula (AlunoID, CursoID, DataMatricula) VALUES (aluno_id, curso_id, CURRENT_DATE);
END //
DELIMITER ;

-- Inserindo exemplos na tabela Area
INSERT INTO Area (AreaID, NomeArea) VALUES
(1, 'Ciências Exatas'),
(2, 'Ciências Humanas'),
(3, 'Ciências Biológicas');

-- Inserindo exemplos na tabela Curso
INSERT INTO Curso (CursoID, NomeCurso, AreaID) VALUES
(1, 'Matemática', 1),
(2, 'História', 2),
(3, 'Biologia', 3);

-- Inserindo exemplos na tabela Aluno
INSERT INTO Aluno (AlunoID, Nome, Sobrenome, Email) VALUES
(1, 'Matheus', 'Laia', 'matheus.laia@dominio.com'),
(2, 'Ricardo', 'Laia', 'ricardo.laia@dominio.com'),
(3, 'Valmir', 'Laia', 'valmir.laia@dominio.com');

-- Inserindo exemplos na tabela Matricula
INSERT INTO Matricula (MatriculaID, AlunoID, CursoID, DataMatricula) VALUES
(1, 1, 1, '2023-11-23'),
(2, 2, 2, '2020-01-19'),
(3, 3, 3, '2021-08-15');

-- Rotina para inserir um novo curso
DELIMITER //
CREATE PROCEDURE InserirNovoCurso(
    IN p_NomeCurso VARCHAR(50),
    IN p_NomeArea VARCHAR(50)
)
BEGIN
    DECLARE area_id INT;
    
    -- Verifica se a área já existe
    SELECT AreaID INTO area_id FROM Area WHERE NomeArea = p_NomeArea;
    
    -- Se não existir, insere a área
    IF area_id IS NULL THEN
        INSERT INTO Area (NomeArea) VALUES (p_NomeArea);
        SET area_id = LAST_INSERT_ID();
    END IF;
    
    -- Insere o novo curso
    INSERT INTO Curso (NomeCurso, AreaID) VALUES (p_NomeCurso, area_id);
END //
DELIMITER ;

CALL InserirNovoCurso('ADS', 'Tecnologia');
