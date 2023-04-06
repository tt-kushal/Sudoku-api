Rails.application.routes.draw do
  post '/sudoku/solve', to: 'sudoku#solve'

end
