-- ========= Creación de Tablas Principales (sin dependencias) =========

CREATE TABLE Region (
    idRegion SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Cultivo (
    idCultivo SERIAL PRIMARY KEY,
    nombreComun VARCHAR(100) NOT NULL,
    nombreCientifico VARCHAR(100),
    descripcion TEXT,
    imagenURL VARCHAR(255)
);

-- ========= Creación de Tablas de Personas (Herencia) =========

CREATE TABLE Persona (
    idPersona SERIAL PRIMARY KEY,
    nombreCompleto VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    escolaridad VARCHAR(100),
    CURP VARCHAR(18) UNIQUE,
    idRegion INT,
    FOREIGN KEY (idRegion) REFERENCES Region(idRegion)
);

CREATE TABLE Usuario (
    idUsuario SERIAL PRIMARY KEY,
    idPersona INT NOT NULL UNIQUE, -- 'UNIQUE' para forzar la relación 1:1
    contrasena VARCHAR(255) NOT NULL, -- En producción, esto debe ser un hash
    fechaRegistro DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (idPersona) REFERENCES Persona(idPersona) ON DELETE CASCADE
);

CREATE TABLE Agricultor (
    idAgricultor SERIAL PRIMARY KEY,
    idPersona INT NOT NULL UNIQUE,
    FOREIGN KEY (idPersona) REFERENCES Persona(idPersona) ON DELETE CASCADE
);

CREATE TABLE Experto (
    idExperto SERIAL PRIMARY KEY,
    idPersona INT NOT NULL UNIQUE,
    especialidad VARCHAR(150),
    cedulaProfesional VARCHAR(100),
    esVerificado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idPersona) REFERENCES Persona(idPersona) ON DELETE CASCADE
);

-- ========= Creación de Tablas de Contenido y Eventos =========

CREATE TABLE Publicacion (
    idPublicacion SERIAL PRIMARY KEY,
    idUsuario INT NOT NULL, -- El autor (Usuario, que puede ser Agricultor o Experto)
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT,
    fechaPublicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fotoURL VARCHAR(255),
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Respuesta (
    idRespuesta SERIAL PRIMARY KEY,
    idPublicacion INT NOT NULL,
    idUsuario INT NOT NULL, -- El autor de la respuesta
    contenido TEXT NOT NULL,
    fechaRespuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    esVerificadaPorExperto BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idPublicacion) REFERENCES Publicacion(idPublicacion) ON DELETE CASCADE,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Guia (
    idGuia SERIAL PRIMARY KEY,
    idCultivo INT NOT NULL,
    idExperto INT NOT NULL, -- El autor (Experto)
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT,
    tipo VARCHAR(50),
    esVerificada BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idCultivo) REFERENCES Cultivo(idCultivo),
    FOREIGN KEY (idExperto) REFERENCES Experto(idExperto)
);

CREATE TABLE Alerta (
    idAlerta SERIAL PRIMARY KEY,
    idExperto INT NOT NULL, -- El Experto que la emite
    idRegion INT NOT NULL, -- La Región a la que aplica
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fechaEmision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nivelRiesgo VARCHAR(50),
    FOREIGN KEY (idExperto) REFERENCES Experto(idExperto),
    FOREIGN KEY (idRegion) REFERENCES Region(idRegion)
);

CREATE TABLE CalendarioAgricola (
    idEvento SERIAL PRIMARY KEY,
    idCultivo INT NOT NULL,
    idRegion INT NOT NULL, -- Para qué región aplica este evento
    actividad VARCHAR(255) NOT NULL,
    fechaInicio DATE,
    fechaFin DATE,
    FOREIGN KEY (idCultivo) REFERENCES Cultivo(idCultivo),
    FOREIGN KEY (idRegion) REFERENCES Region(idRegion)
);

-- ========= Tabla de Enlace para Relación N:N (Muchos a Muchos) =========

-- Tabla para la relación N:N "Siembra" entre Agricultor y Cultivo
CREATE TABLE Agricultor_Cultivos (
    idAgricultor INT NOT NULL,
    idCultivo INT NOT NULL,
    PRIMARY KEY (idAgricultor, idCultivo),
    FOREIGN KEY (idAgricultor) REFERENCES Agricultor(idAgricultor) ON DELETE CASCADE,
    FOREIGN KEY (idCultivo) REFERENCES Cultivo(idCultivo) ON DELETE CASCADE
);