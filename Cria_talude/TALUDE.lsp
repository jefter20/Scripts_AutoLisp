;;;========================================================================
;;; COMANDO: TALUDE
;;; DESCRIÇÃO: Gera linhas transversais de talude de forma otimizada.
;;;========================================================================

(defun c:TALUDE ( / entTop entBot dist spc lenTop curDist ptTop ptBot ptMid isShort undoObj doc)
  ;; Carrega as funções do Visual LISP
  (vl-load-com)
  
  ;; Configura o Undo para poder desfazer tudo com um único Ctrl+Z
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc)

  ;; Solicita as linhas ao usuário
  (setq entTop (car (entsel "\nSelecione a linha da CRISTA (topo do talude): ")))
  (if (not entTop) (progn (princ "\nCrista não selecionada. Comando cancelado.") (exit)))

  (setq entBot (car (entsel "\nSelecione a linha do PÉ (base do talude): ")))
  (if (not entBot) (progn (princ "\nPé não selecionado. Comando cancelado.") (exit)))

  ;; Solicita o espaçamento
  (setq spc (getreal "\nInforme o espaçamento entre as linhas (ex: 2.0): "))
  (if (not spc) (setq spc 2.0)) ; Valor padrão caso o usuário apenas dê Enter

  ;; Obtém o comprimento total da linha da Crista
  (setq lenTop (vlax-curve-getDistAtParam entTop (vlax-curve-getEndParam entTop)))
  (setq curDist 0.0)
  (setq isShort nil) ; Variável para alternar entre linha longa e curta

  ;; Loop de criação das linhas
  (while (<= curDist lenTop)
    ;; Pega o ponto na crista com base na distância atual
    (setq ptTop (vlax-curve-getPointAtDist entTop curDist))
    
    ;; Acha o ponto mais próximo no pé do talude (perpendicular)
    (setq ptBot (vlax-curve-getClosestPointTo entBot ptTop))

    (if isShort
      ;; Desenha linha CURTA (50% do comprimento)
      (progn
        (setq ptMid (list
                      (+ (car ptTop) (* 0.5 (- (car ptBot) (car ptTop))))
                      (+ (cadr ptTop) (* 0.5 (- (cadr ptBot) (cadr ptTop))))
                      (+ (caddr ptTop) (* 0.5 (- (caddr ptBot) (caddr ptTop))))
                    ))
        ;; Cria a linha diretamente no banco de dados (muito mais rápido que o comando "LINE")
        (entmake (list '(0 . "LINE") (cons 10 ptTop) (cons 11 ptMid)))
        (setq isShort nil) ; Próxima linha será longa
      )
      ;; Desenha linha LONGA (100% do comprimento)
      (progn
        (entmake (list '(0 . "LINE") (cons 10 ptTop) (cons 11 ptBot)))
        (setq isShort T) ; Próxima linha será curta
      )
    )
    
    ;; Avança para o próximo ponto
    (setq curDist (+ curDist spc))
  )

  ;; Finaliza o Undo
  (vla-EndUndoMark doc)
  
  (princ "\nRepresentação do talude gerada com sucesso!")
  (princ)
)