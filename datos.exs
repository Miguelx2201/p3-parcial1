defmodule Datos do
  def confeccionistas do
    [
      %{codigo: "C01", nombre: "Miguel Gutierrez", alquiler: true},
      %{codigo: "C02", nombre: "Natalia Contreras", alquiler: false},
      %{codigo: "C03", nombre: "Carlos Gómez", alquiler: true},
      %{codigo: "C04", nombre: "Ana Martínez", alquiler: false},
      %{codigo: "C05", nombre: "Luisa Fernández", alquiler: true},
      %{codigo: "C06", nombre: "Jorge Ramírez", alquiler: false},
      %{codigo: "C07", nombre: "Diana López", alquiler: true},
      %{codigo: "C08", nombre: "Pedro Morales", alquiler: false},
      %{codigo: "C09", nombre: "Sofía Castro", alquiler: false},
      %{codigo: "C10", nombre: "Mateo Ortiz", alquiler: true},
      %{codigo: "C11", nombre: "Valentina Castillo", alquiler: false},
      %{codigo: "C12", nombre: "Nelly Mora", alquiler: false}
    ]
  end

  def lineas do
    [
      %{id: "L1", nombre: "Línea Norte", puestos: 5},
      %{id: "L2", nombre: "Línea Central", puestos: 5},
      %{id: "L3", nombre: "Línea Sur", puestos: 10},
      %{id: "L4", nombre: "Línea Oriente", puestos: 8}
    ]
  end

  def lotes do
    # 1. Lotes invalidos (2 por cada motivo)
     [
      # Regla 1: Confeccionista desconocido
      %{codigo_confeccionista: "C99", linea: "L1", dia: 1, prendas: 80, defectos: 1.0},
      %{codigo_confeccionista: "C88", linea: "L2", dia: 2, prendas: 60, defectos: 2.0},
      # Regla 2: Línea desconocida
      %{codigo_confeccionista: "C01", linea: "LX", dia: 1, prendas: 70, defectos: 1.5},
      %{codigo_confeccionista: "C02", linea: "LZ", dia: 3, prendas: 50, defectos: 3.0},
      # Regla 3: Día inválido
      %{codigo_confeccionista: "C01", linea: "L1", dia: 0, prendas: 90, defectos: 0.0},
      %{codigo_confeccionista: "C03", linea: "L3", dia: 7, prendas: 100, defectos: 4.0},
      # Regla 4: Prendas fuera de rango (<= 0 o > 180)
      %{codigo_confeccionista: "C01", linea: "L1", dia: 2, prendas: 0, defectos: 1.0},
      %{codigo_confeccionista: "C04", linea: "L2", dia: 4, prendas: 200, defectos: 2.0},
      # Regla 5: Porcentaje de defectos inválido (< 0 o > 100)
      %{codigo_confeccionista: "C02", linea: "L2", dia: 5, prendas: 110, defectos: -1.0},
      %{codigo_confeccionista: "C05", linea: "L3", dia: 6, prendas: 85, defectos: 105.0},

    # 2. Lotes validos (80 lotes distribuidos en los 6 días)
      # --- DÍA 1 (Total: 620 prendas -> Cumple meta de 600) ---
      %{codigo_confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},  # María (Ejemplo parcial)
      %{codigo_confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7.0},  # María (Ejemplo parcial)
      %{codigo_confeccionista: "C02", linea: "L1", dia: 1, prendas: 150, defectos: 1.0}, # Andrés (Líder Día 1: 150)
      %{codigo_confeccionista: "C03", linea: "L2", dia: 1, prendas: 130, defectos: 0.5},
      %{codigo_confeccionista: "C04", linea: "L3", dia: 1, prendas: 115, defectos: 2.0},
      %{codigo_confeccionista: "C05", linea: "L3", dia: 1, prendas: 50, defectos: 12.0},
      %{codigo_confeccionista: "C06", linea: "L1", dia: 1, prendas: 50, defectos: 4.0},

      # --- DÍA 2 (Total: 580 prendas -> NO cumple meta de 600) ---
      %{codigo_confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12.0}, # María (Ejemplo parcial)
      %{codigo_confeccionista: "C02", linea: "L2", dia: 2, prendas: 140, defectos: 0.8}, # Andrés (Líder Día 2: 140)
      %{codigo_confeccionista: "C03", linea: "L3", dia: 2, prendas: 110, defectos: 1.2},
      %{codigo_confeccionista: "C04", linea: "L1", dia: 2, prendas: 120, defectos: 3.0},
      %{codigo_confeccionista: "C05", linea: "L2", dia: 2, prendas: 60, defectos: 5.0},
      %{codigo_confeccionista: "C05", linea: "L3", dia: 2, prendas: 60, defectos: 6.0},

      # --- DÍA 3 (Total: 650 prendas -> Cumple meta de 600) ---
      %{codigo_confeccionista: "C02", linea: "L3", dia: 3, prendas: 160, defectos: 1.0}, # Empate Líder Día 3 (160)
      %{codigo_confeccionista: "C06", linea: "L2", dia: 3, prendas: 160, defectos: 0.5}, # Empate Líder Día 3 (160)
      %{codigo_confeccionista: "C07", linea: "L1", dia: 3, prendas: 130, defectos: 2.0},
      %{codigo_confeccionista: "C08", linea: "L3", dia: 3, prendas: 100, defectos: 8.0},
      %{codigo_confeccionista: "C01", linea: "L3", dia: 3, prendas: 100, defectos: 1.0},

      # --- DÍA 4 (Total: 510 prendas -> NO cumple meta de 600) ---
      %{codigo_confeccionista: "C03", linea: "L1", dia: 4, prendas: 150, defectos: 0.0}, # Camila (Líder Día 4: 150)
      %{codigo_confeccionista: "C07", linea: "L2", dia: 4, prendas: 120, defectos: 1.5},
      %{codigo_confeccionista: "C08", linea: "L1", dia: 4, prendas: 120, defectos: 4.0},
      %{codigo_confeccionista: "C06", linea: "L3", dia: 4, prendas: 120, defectos: 2.0},

      # --- DÍA 5 (Total: 610 prendas -> Cumple meta de 600) ---
      %{codigo_confeccionista: "C02", linea: "L1", dia: 5, prendas: 170, defectos: 0.5}, # Andrés (Líder Día 5: 170)
      %{codigo_confeccionista: "C04", linea: "L2", dia: 5, prendas: 150, defectos: 2.5},
      %{codigo_confeccionista: "C07", linea: "L3", dia: 5, prendas: 140, defectos: 1.0},
      %{codigo_confeccionista: "C08", linea: "L2", dia: 5, prendas: 150, defectos: 3.5},

      # --- DÍA 6 (Total: 480 prendas -> NO cumple meta de 600) ---
      %{codigo_confeccionista: "C02", linea: "L2", dia: 6, prendas: 130, defectos: 1.0}, # Andrés (Líder Día 6: 130)
      %{codigo_confeccionista: "C06", linea: "L1", dia: 6, prendas: 125, defectos: 0.0},
      %{codigo_confeccionista: "C07", linea: "L3", dia: 6, prendas: 125, defectos: 2.0},
      %{codigo_confeccionista: "C09", linea: "L1", dia: 6, prendas: 100, defectos: 0.0}, # C09 solo tiene 2 lotes (Excluida R6)

      # --- DISTRIBUCIÓN SEMANAL RESTANTE (Lotes 31 a 80) ---
      %{codigo_confeccionista: "C01", linea: "L2", dia: 4, prendas: 80, defectos: 3.0},
      %{codigo_confeccionista: "C01", linea: "L3", dia: 5, prendas: 85, defectos: 2.5},
      %{codigo_confeccionista: "C01", linea: "L1", dia: 6, prendas: 90, defectos: 1.0},

      %{codigo_confeccionista: "C02", linea: "L1", dia: 2, prendas: 70, defectos: 1.2},
      %{codigo_confeccionista: "C02", linea: "L2", dia: 4, prendas: 80, defectos: 0.5},

      %{codigo_confeccionista: "C03", linea: "L3", dia: 3, prendas: 75, defectos: 2.0},
      %{codigo_confeccionista: "C03", linea: "L2", dia: 5, prendas: 95, defectos: 4.5},
      %{codigo_confeccionista: "C03", linea: "L1", dia: 6, prendas: 80, defectos: 1.0},

      %{codigo_confeccionista: "C04", linea: "L1", dia: 3, prendas: 85, defectos: 1.8},
      %{codigo_confeccionista: "C04", linea: "L3", dia: 4, prendas: 90, defectos: 2.0},
      %{codigo_confeccionista: "C04", linea: "L2", dia: 6, prendas: 100, defectos: 3.2},

      %{codigo_confeccionista: "C05", linea: "L1", dia: 3, prendas: 70, defectos: 4.0},
      %{codigo_confeccionista: "C05", linea: "L2", dia: 4, prendas: 75, defectos: 2.0},
      %{codigo_confeccionista: "C05", linea: "L3", dia: 5, prendas: 80, defectos: 1.5},
      %{codigo_confeccionista: "C05", linea: "L1", dia: 6, prendas: 85, defectos: 5.5},

      %{codigo_confeccionista: "C06", linea: "L2", dia: 1, prendas: 90, defectos: 1.0},
      %{codigo_confeccionista: "C06", linea: "L3", dia: 2, prendas: 95, defectos: 0.8},
      %{codigo_confeccionista: "C06", linea: "L1", dia: 5, prendas: 100, defectos: 0.5},

      %{codigo_confeccionista: "C07", linea: "L1", dia: 1, prendas: 80, defectos: 2.0},
      %{codigo_confeccionista: "C07", linea: "L2", dia: 2, prendas: 85, defectos: 1.5},

      %{codigo_confeccionista: "C08", linea: "L2", dia: 1, prendas: 75, defectos: 3.0},
      %{codigo_confeccionista: "C08", linea: "L3", dia: 2, prendas: 80, defectos: 2.5},
      %{codigo_confeccionista: "C08", linea: "L1", dia: 6, prendas: 90, defectos: 4.0},

      %{codigo_confeccionista: "C09", linea: "L2", dia: 3, prendas: 80, defectos: 0.0}, # Segundo y último lote de C09

      %{codigo_confeccionista: "C10", linea: "L1", dia: 1, prendas: 60, defectos: 2.0},
      %{codigo_confeccionista: "C10", linea: "L2", dia: 2, prendas: 65, defectos: 1.5},
      %{codigo_confeccionista: "C10", linea: "L3", dia: 3, prendas: 70, defectos: 3.0},
      %{codigo_confeccionista: "C10", linea: "L1", dia: 4, prendas: 75, defectos: 2.5},
      %{codigo_confeccionista: "C10", linea: "L2", dia: 5, prendas: 80, defectos: 1.0},

      %{codigo_confeccionista: "C11", linea: "L1", dia: 1, prendas: 85, defectos: 0.5},
      %{codigo_confeccionista: "C11", linea: "L2", dia: 2, prendas: 90, defectos: 1.0},
      %{codigo_confeccionista: "C11", linea: "L3", dia: 3, prendas: 95, defectos: 1.5},
      %{codigo_confeccionista: "C11", linea: "L1", dia: 4, prendas: 100, defectos: 2.0},
      %{codigo_confeccionista: "C11", linea: "L2", dia: 5, prendas: 105, defectos: 0.8},
      %{codigo_confeccionista: "C11", linea: "L3", dia: 6, prendas: 110, defectos: 1.2},

      %{codigo_confeccionista: "C01", linea: "L3", dia: 4, prendas: 60, defectos: 2.0},
      %{codigo_confeccionista: "C02", linea: "L3", dia: 5, prendas: 70, defectos: 1.0},
      %{codigo_confeccionista: "C03", linea: "L2", dia: 6, prendas: 75, defectos: 1.5},
      %{codigo_confeccionista: "C04", linea: "L1", dia: 1, prendas: 65, defectos: 2.0},
      %{codigo_confeccionista: "C05", linea: "L2", dia: 2, prendas: 70, defectos: 3.0},
      %{codigo_confeccionista: "C06", linea: "L3", dia: 3, prendas: 80, defectos: 1.0},
      %{codigo_confeccionista: "C07", linea: "L1", dia: 4, prendas: 85, defectos: 1.2},
      %{codigo_confeccionista: "C08", linea: "L2", dia: 5, prendas: 90, defectos: 2.0},
      %{codigo_confeccionista: "C10", linea: "L3", dia: 6, prendas: 95, defectos: 1.5},
      %{codigo_confeccionista: "C01", linea: "L1", dia: 3, prendas: 50, defectos: 1.0},
      %{codigo_confeccionista: "C02", linea: "L2", dia: 4, prendas: 60, defectos: 0.5},
      %{codigo_confeccionista: "C03", linea: "L3", dia: 5, prendas: 70, defectos: 2.0},
      %{codigo_confeccionista: "C04", linea: "L1", dia: 6, prendas: 80, defectos: 1.0},
      %{codigo_confeccionista: "C05", linea: "L2", dia: 1, prendas: 55, defectos: 3.5},
      %{codigo_confeccionista: "C06", linea: "L3", dia: 2, prendas: 65, defectos: 0.5},
      %{codigo_confeccionista: "C07", linea: "L1", dia: 3, prendas: 75, defectos: 1.0},
      %{codigo_confeccionista: "C08", linea: "L2", dia: 4, prendas: 85, defectos: 2.2},
      %{codigo_confeccionista: "C10", linea: "L3", dia: 5, prendas: 90, defectos: 1.8},
      %{codigo_confeccionista: "C11", linea: "L1", dia: 6, prendas: 95, defectos: 1.0}
    ]

  end

end
