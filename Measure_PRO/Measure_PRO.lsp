(defun c:MeasurePRO (/ *error* curve blkName incr ctr len dist pt param deriv ang angDeg blkEnt ss1 i ent entData old_osmode old_cmdecho lastEnt newEnt)

  ;; Tratamento de erro
  (defun *error* (msg)
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*QUIT*")))
      (princ (strcat "\nErro: " msg))
    )
    (princ)
  )

  (vl-load-com)
  
  ;; Salva variáveis e desliga snaps
  (setq old_osmode (getvar "OSMODE"))
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)

  ;; 1. Seleção do Eixo
  (setq curve (car (entsel "\nSelecione o Eixo (Polyline/Line/Arc): ")))
  
  (if curve
    (progn
      (setq blkName (getstring "\nNome do Bloco da estaca: "))
      
      (if (tblsearch "BLOCK" blkName)
        (progn
          ;; Inputs do usuário
          (setq incr (getreal "\nDistância entre estacas <20.0>: "))
          (if (not incr) (setq incr 20.0))

          (setq ctr (getint "\nNúmero da primeira estaca <0>: "))
          (if (not ctr) (setq ctr 0))

          (setq len (vlax-curve-getDistAtParam curve (vlax-curve-getEndParam curve)))
          (setq dist 0.0)

          (princ "\nGerando, quebrando e numerando estacas... Aguarde.")

          ;; 2. Loop de inserção
          (while (<= dist len)
             (setq pt (vlax-curve-getPointAtDist curve dist))
             
             ;; Cálculo do ângulo
             (setq param (vlax-curve-getParamAtDist curve dist))
             (setq deriv (vlax-curve-getFirstDeriv curve param))
             (setq ang (angle '(0 0 0) deriv))
             (setq angDeg (* (/ ang pi) 180.0))

             ;; Inserir Bloco
             (setq lastEnt (entlast)) ;; Marca a última entidade antes de inserir
             (command "-INSERT" blkName pt "1" "1" angDeg)
             (setq blkEnt (entlast)) ;; O bloco recém inserido

             ;; 3. Primeira Explosão
             (setq lastEnt (entlast)) ;; Marca antes de explodir
             (command "_.EXPLODE" blkEnt)
             
             ;; Coleta tudo o que foi gerado pela explosão
             (setq ss1 (ssadd))
             (setq newEnt lastEnt)
             (while (setq newEnt (entnext newEnt))
               (ssadd newEnt ss1)
             )

             ;; 4. Varre os pedaços para Segunda Explosão e Numeração
             (setq i 0)
             (while (< i (sslength ss1))
               (setq ent (ssname ss1 i))
               (setq entData (entget ent))
               
               ;; Se o pedaço for OUTRO bloco (aninhado), explode de novo
               (if (= (cdr (assoc 0 entData)) "INSERT")
                 (progn
                   (setq lastEnt (entlast))
                   (command "_.EXPLODE" ent)
                   (setq newEnt lastEnt)
                   ;; Varre os pedaços dessa segunda explosão procurando o texto
                   (while (setq newEnt (entnext newEnt))
                     (setq entData (entget newEnt))
                     (if (wcmatch (cdr (assoc 0 entData)) "*TEXT")
                       (progn
                         (setq entData (subst (cons 1 (itoa ctr)) (assoc 1 entData) entData))
                         (entmod entData)
                       )
                     )
                   )
                 )
                 
                 ;; Se o pedaço da primeira explosão já for um texto, atualiza direto
                 (if (wcmatch (cdr (assoc 0 entData)) "*TEXT")
                   (progn
                     (setq entData (subst (cons 1 (itoa ctr)) (assoc 1 entData) entData))
                     (entmod entData)
                   )
                 )
               )
               (setq i (1+ i))
             )

             ;; Incrementa distância e contador de numeração
             (setq dist (+ dist incr))
             (setq ctr (1+ ctr))
          )
          (princ (strcat "\nConcluído! Última estaca: " (itoa (1- ctr))))
        )
        (princ "\nErro: Bloco não encontrado no desenho.")
      )
    )
    (princ "\nErro: Nenhum objeto selecionado.")
  )

  ;; Restaura configurações
  (setvar "OSMODE" old_osmode)
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)