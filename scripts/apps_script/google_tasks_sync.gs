/**
 * Sincroniza tarefas concluídas com a base de dados.
 * Ative o serviço 'Tasks API' antes de rodar.
 */
function syncGoogleTasksToDB() {
  const taskLists = Tasks.Tasklists.list().items;
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("fact_execucoes");
  
  taskLists.forEach(list => {
    // Busca tarefas concluídas nas últimas 24h
    const optionalArgs = {
      completedMin: new Date(new Date().getTime() - (24 * 60 * 60 * 1000)).toISOString(),
      showCompleted: true
    };
    
    const tasks = Tasks.Tasks.list(list.id, optionalArgs).items;
    
    if (tasks) {
      tasks.forEach(task => {
        if (task.status === "completed") {
          // Registra a conclusão. O meta_id deve ser mapeado via título da tarefa
          sheet.appendRow([
            new Date(),      // timestamp
            task.title,      // título (usar para buscar meta_id no SQL)
            task.completed,  // data de conclusão real
            list.title       // lista de origem (Single, Daily, etc)
          ]);
        }
      });
    }
  });
}