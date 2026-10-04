defmodule Datos do
  def confeccionistas do
    [
      %{codigo: "C01", nombre: "Miguel Gutierrez", alquiler: true},
      %{codigo: "C02", nombre: "Natalia Contreras", alquiler: false},
      %{codigo: "C03", nombre: "Carlos Gómez", alquiler: true},
      %{codigo: "C04", nombre: "Ana Martínez", alquiler: true},
      %{codigo: "C05", nombre: "Luisa Fernández", alquiler: true},
      %{codigo: "C06", nombre: "Jorge Ramírez", alquiler: false},
      %{codigo: "C07", nombre: "Diana López", alquiler: false},
      %{codigo: "C08", nombre: "Pedro Morales", alquiler: true},
      %{codigo: "C09", nombre: "Sofía Castro", alquiler: false},
      %{codigo: "C10", nombre: "Mateo Ortiz", alquiler: false},
      %{codigo: "C09", nombre: "Valentina Castillo", alquiler: false},
      %{codigo: "C10", nombre: "Nelly Mora", alquiler: false}
    ]
  end

  def lineas do
    [
      %{id: "L1", nombre: "Línea Norte", puestos: 6},
      %{id: "L2", nombre: "Línea Central", puestos: 4},
      %{id: "L3", nombre: "Línea Sur", puestos: 5},
      %{id: "L4", nombre: "Línea Oriente", puestos: 3}
    ]
  end

  def lotes do
    # 1. Lotes invalidos (2 por cada motivo)
    lotes_invalidos = [
      # Motivo 1: :confeccionista desconocido
      %{codigo_confeccionista: "C99", linea: "L1", dia: 1, prendas: 80, defectos: 1.0},
      %{codigo_confeccionista: "C88", linea: "L2", dia: 2, prendas: 60, defectos: 2.0},
      # Motivo 2: :linea desconocida
      %{codigo_confeccionista: "C01", linea: "LX", dia: 1, prendas: 70, defectos: 1.5},
      %{codigo_confeccionista: "C02", linea: "LZ", dia: 3, prendas: 50, defectos: 3.0},
      # Motivo 3: :dia invalido
      %{codigo_confeccionista: "C01", linea: "L1", dia: 0, prendas: 90, defectos: 0.0},
      %{codigo_confeccionista: "C03", linea: "L3", dia: 7, prendas: 100, defectos: 4.0},
      # Motivo 4: :prendas fuera de rango
      %{codigo_confeccionista: "C01", linea: "L1", dia: 2, prendas: 0, defectos: 1.0},
      %{codigo_confeccionista: "C04", linea: "L4", dia: 4, prendas: 200, defectos: 2.0},
      # Motivo 5: :porcentaje invalido
      %{codigo_confeccionista: "C02", linea: "L2", dia: 5, prendas: 110, defectos: -1.0},
      %{codigo_confeccionista: "C05", linea: "L3", dia: 6, prendas: 85, defectos: 105.0}
    ]

    # 2. Lotes validos (80 lotes distribuidos en los 6 días)
    lotes_validos =
    for i <- 1..80 do
      conf = rem(i, 12) + 1
      lin = rem(i, 4) + 1
      dia = rem(i, 6) + 1
      %{
      codigo_confeccionista: "C" <> String.pad_leading("#{conf}", 2, "0"),
      linea: "L#{lin}",
      dia: dia,
      prendas: 50 + rem(i * 7, 100),
      defectos: Float.round(rem(i, 8) * 1.2, 1)
      }
    end

    #Antes se tenia de esta manera [lotes_validos|lotes_invalidos]
    # pero se descubrio que retorna una lista de listas; [lotes_validos, lotes_invalidos] y no una lista plana de lotes.
    # Entonces se usa la siguiente forma pero con los lotes invalidos primero, asi esa accion tendra complejidad computacional
    # O(10) ya que la lista de lotes invalidos es de longitud 10
    lotes_invalidos ++ lotes_validos
  end

end
