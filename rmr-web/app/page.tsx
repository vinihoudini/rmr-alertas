async function getAlertas() {
  const res = await fetch("http://localhost:8000/api/v1/alertas")
  return res.json()
}

export default async function Home() {
  const alertas = await getAlertas()

  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold mb-6">Alertas Climáticos — RMR</h1>
      <div className="flex flex-col gap-4">
        {alertas.map((item: any) => (
          <div key={item.id} className="border rounded p-4">
            <p className="font-semibold">{item.municipio}</p>
            <p>{item.nivel_alerta}</p>
            <p className="text-sm text-gray-500">Atualizado: {item.atualizacao}</p>
          </div>
        ))}
      </div>
    </main>
  )
}