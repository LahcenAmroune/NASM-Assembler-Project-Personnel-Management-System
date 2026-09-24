section .data
    ; Définitions des données statiques utilisées dans le programme
    menu db "1. Enregistrer du personnel",10            ; Chaîne pour l’option 1, suivie d’un saut de ligne LF (10)
         db "2. Lister des personnes enregistrees",10   ; Chaîne pour l’option 2, suivie de LF
         db "3. Supprimer une personne specifique",10   ; Chaîne pour l’option 3, suivie de LF
         db "4. Afficher la personne la plus agee et la plus jeune",10 ; Chaîne pour l’option 4, suivie de LF
         db "5. Afficher l'age moyen",10               ; Chaîne pour l’option 5, suivie de LF
         db "6. Quitter le programme",10               ; Chaîne pour l’option 6, suivie de LF
         db "Votre choix: ",0                          ; Invite pour entrer un choix, terminée par un zéro (pas de LF ici)
    menu_len equ $-menu                                ; Calcule la longueur totale du menu en octets (différence entre l’adresse actuelle et le début de menu)

    prompt_input db "Entrez le nom et l'age (ex: Bob 25): ",0 ; Chaîne pour demander le nom et l’âge, terminée par zéro
    prompt_input_len equ $-prompt_input                ; Calcule la longueur de prompt_input en octets

    success_msg db "Personne enregistree!",10,0        ; Message affiché après un enregistrement réussi, avec LF et zéro
    success_len equ $-success_msg                      ; Calcule la longueur de success_msg en octets

    error_msg db "Entree invalide! (Nom < 20 char, 0 < age <= 120)",10,0 ; Message d’erreur pour entrée invalide, avec LF et zéro
    error_len equ $-error_msg                          ; Calcule la longueur de error_msg en octets

    list_header db "Liste des personnes:",10,0         ; En-tête pour la liste des personnes, avec LF et zéro
    list_header_len equ $-list_header                  ; Calcule la longueur de list_header en octets

    no_data_msg db "Aucune personne n'est encore enregistree!",10,0 ; Message si aucune donnée n’est enregistrée, avec LF et zéro
    no_data_len equ $-no_data_msg                      ; Calcule la longueur de no_data_msg en octets

    prompt_delete db "Suppression la personne (numero): ",0 ; Invite pour entrer le numéro de la personne à supprimer, terminée par zéro
    prompt_delete_len equ $-prompt_delete              ; Calcule la longueur de prompt_delete en octets

    delete_success db "Personne ",0                    ; Début du message de suppression réussie, terminée par zéro (suite ajoutée dynamiquement)
    delete_success_len equ $-delete_success            ; Calcule la longueur de delete_success en octets

    delete_success_end db " a ete supprimee!",10,0     ; Fin du message de suppression réussie, avec LF et zéro
    delete_success_end_len equ $-delete_success_end    ; Calcule la longueur de delete_success_end en octets

    delete_fail db "Cette personne n'existe pas!",10,0 ; Message si la personne à supprimer n’existe pas, avec LF et zéro
    delete_fail_len equ $-delete_fail                  ; Calcule la longueur de delete_fail en octets

    extremes_header db "Plus agee et plus jeune:",10,0 ; En-tête pour afficher les âges extrêmes, avec LF et zéro
    extremes_header_len equ $-extremes_header          ; Calcule la longueur de extremes_header en octets

    avg_header db "Age en moyenne:",10,0               ; En-tête pour l’âge moyen, avec LF et zéro
    avg_header_len equ $-avg_header                    ; Calcule la longueur de avg_header en octets

    avg_open db "(",0                                  ; Parenthèse ouvrante pour la liste des âges, terminée par zéro
    avg_close db ")",10,0                              ; Parenthèse fermante avec LF et zéro pour terminer la liste des âges

    invalid_choice_msg db "Precisez votre choix avec un seul numero!",10,0 ; Message pour un choix invalide, avec LF et zéro
    invalid_choice_len equ $-invalid_choice_msg        ; Calcule la longueur de invalid_choice_msg en octets

    newline db 10,0                                    ; Caractère de saut de ligne LF seul, suivi d’un zéro
    space db " ",0                                     ; Caractère espace seul, suivi d’un zéro

    personnes times 10*64 db 0                         ; Tableau pour stocker 10 noms (64 octets chacun), initialisé à zéro
    ages times 10 dd 0                                 ; Tableau pour stocker 10 âges (4 octets chacun), initialisé à zéro
    count dd 0                                         ; Compteur du nombre de personnes enregistrées, initialisé à 0 (double mot, 4 octets)
    input times 256 db 0                               ; Tampon pour stocker les entrées utilisateur, 256 octets initialisés à zéro
    input_length dd 0                                  ; Variable pour stocker la longueur de l’entrée lue, initialisée à 0 (4 octets)
    num_buffer times 11 db 0                           ; Tampon pour convertir des nombres en texte (10 chiffres max + zéro)

section .text
global _start

_start:
    call display_menu                                  ; Point d’entrée du programme : appelle la fonction pour afficher le menu

; Affiche le menu, lit le choix utilisateur, et redirige vers la fonction correspondante
display_menu:
    mov ecx, num_buffer                                ; Charge l’adresse de num_buffer dans ECX pour l’effacer
    mov edx, 11                                        ; Définit la taille de num_buffer (11 octets) comme compteur
clear_num_buffer_loop:
    mov byte [ecx], 0                                  ; Met l’octet courant de num_buffer à zéro
    inc ecx                                            ; Passe à l’octet suivant dans num_buffer
    dec edx                                            ; Décrémente le compteur d’octets restants
    jnz clear_num_buffer_loop                          ; Continue la boucle si EDX n’est pas zéro

    mov eax, 4                                         ; Appel système sys_write (4) pour écrire sur la sortie standard
    mov ebx, 1                                         ; Descripteur de fichier 1 (stdout)
    mov ecx, menu                                      ; Pointeur vers la chaîne menu à afficher
    mov edx, menu_len                                  ; Longueur de la chaîne menu en octets
    int 0x80                                           ; Interruption pour exécuter l’appel système (affiche le menu)

    mov ecx, input                                     ; Charge l’adresse du tampon input dans ECX pour l’effacer
    mov edx, 256                                       ; Définit la taille du tampon input (256 octets) comme compteur
clear_input_loop:
    mov byte [ecx], 0                                  ; Met l’octet courant du tampon input à zéro
    inc ecx                                            ; Passe à l’octet suivant dans input
    dec edx                                            ; Décrémente le compteur d’octets restants
    jnz clear_input_loop                               ; Continue la boucle si EDX n’est pas zéro

    mov eax, 3                                         ; Appel système sys_read (3) pour lire depuis l’entrée standard
    mov ebx, 0                                         ; Descripteur de fichier 0 (stdin)
    mov ecx, input                                     ; Pointeur vers le tampon input pour stocker l’entrée
    mov edx, 3                                         ; Nombre max d’octets à lire (chiffre + LF + éventuel caractère)
    int 0x80                                           ; Interruption pour lire le choix de l’utilisateur

    mov esi, input                                     ; Charge l’adresse du tampon input dans ESI pour analyse
check_choice:
    cmp byte [esi + 1], 0                              ; Compare le 2e octet avec zéro (fin de chaîne possible)
    je single_digit_check                              ; Si zéro, passe à la vérification d’un seul chiffre
    cmp byte [esi + 1], 10                             ; Compare le 2e octet avec LF (fin de ligne)
    je single_digit_check                              ; Si LF, passe à la vérification d’un seul chiffre
    jmp invalid_choice                                 ; Sinon, l’entrée est invalide (trop longue)

single_digit_check:
    cmp byte [esi], '1'                                ; Compare le 1er octet avec '1'
    je register_person                                 ; Si égal à '1', saute à la fonction register_person
    cmp byte [esi], '2'                                ; Compare le 1er octet avec '2'
    je list_people                                     ; Si égal à '2', saute à la fonction list_people
    cmp byte [esi], '3'                                ; Compare le 1er octet avec '3'
    je delete_person                                   ; Si égal à '3', saute à la fonction delete_person
    cmp byte [esi], '4'                                ; Compare le 1er octet avec '4'
    je show_extremes                                   ; Si égal à '4', saute à la fonction show_extremes
    cmp byte [esi], '5'                                ; Compare le 1er octet avec '5'
    je show_average                                    ; Si égal à '5', saute à la fonction show_average
    cmp byte [esi], '6'                                ; Compare le 1er octet avec '6'
    je exit_program                                    ; Si égal à '6', saute à la fonction exit_program
    jmp invalid_choice                                 ; Sinon, l’entrée est invalide

invalid_choice:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, invalid_choice_msg                        ; Pointeur vers le message d’erreur pour choix invalide
    mov edx, invalid_choice_len                        ; Longueur du message d’erreur
    int 0x80                                           ; Affiche le message d’erreur
    jmp display_menu                                   ; Retourne au menu principal

; Gère l’enregistrement d’une nouvelle personne
register_person:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, prompt_input                              ; Pointeur vers l’invite pour entrer nom et âge
    mov edx, prompt_input_len                          ; Longueur de l’invite
    int 0x80                                           ; Affiche l’invite

    mov ecx, input                                     ; Charge l’adresse du tampon input dans ECX pour l’effacer
    mov edx, 256                                       ; Définit la taille du tampon (256 octets) comme compteur
clear_input_register_loop:
    mov byte [ecx], 0                                  ; Met l’octet courant à zéro
    inc ecx                                            ; Passe à l’octet suivant
    dec edx                                            ; Décrémente le compteur
    jnz clear_input_register_loop                      ; Continue la boucle si EDX n’est pas zéro

    mov eax, 3                                         ; Appel système sys_read
    mov ebx, 0                                         ; Descripteur de fichier stdin
    mov ecx, input                                     ; Pointeur vers le tampon input pour stocker l’entrée
    mov edx, 255                                       ; Nombre max d’octets à lire (nom + âge + LF)
    int 0x80                                           ; Lit l’entrée de l’utilisateur (ex: "Bob 25")
    mov [input_length], eax                            ; Stocke la longueur lue dans input_length

    call parse_input                                   ; Appelle la fonction pour analyser l’entrée (nom et âge)
    cmp eax, 0                                         ; Compare la valeur de retour avec 0 (0 = échec, 1 = succès)
    je register_error                                  ; Si échec, saute à register_error

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, success_msg                               ; Pointeur vers le message de succès
    mov edx, success_len                               ; Longueur du message de succès
    int 0x80                                           ; Affiche "Personne enregistree!" avec LF
    jmp display_menu                                   ; Retourne au menu principal (LF déjà dans success_msg)

register_error:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, error_msg                                 ; Pointeur vers le message d’erreur
    mov edx, error_len                                 ; Longueur du message d’erreur
    int 0x80                                           ; Affiche le message d’erreur avec LF
    jmp display_menu                                   ; Retourne au menu principal (LF déjà dans error_msg)

; Analyse l’entrée utilisateur pour extraire nom et âge
parse_input:
    mov eax, [count]                                   ; Charge le nombre actuel de personnes dans EAX
    cmp eax, 10                                        ; Compare avec la limite de 10 personnes
    jge parse_done_fail                                ; Si ≥ 10, le tableau est plein, échec

    imul eax, 64                                       ; Multiplie le compteur par 64 pour calculer l’offset dans personnes
    lea edi, [personnes + eax]                         ; Charge l’adresse de destination pour le nom dans EDI
    mov esi, input                                     ; Charge l’adresse de l’entrée utilisateur dans ESI
    xor ecx, ecx                                       ; Initialise le compteur de caractères à 0

find_space_loop:
    mov al, [esi + ecx]                                ; Charge le caractère courant de l’entrée dans AL
    cmp al, ' '                                        ; Compare avec un espace (séparateur entre nom et âge)
    je found_space                                     ; Si espace trouvé, saute à found_space
    cmp al, 10                                         ; Compare avec LF (fin de ligne sans espace = invalide)
    je parse_done_fail                                 ; Si LF, échec
    cmp al, 0                                          ; Compare avec zéro (fin de chaîne sans espace = invalide)
    je parse_done_fail                                 ; Si zéro, échec
    inc ecx                                            ; Incrémente le compteur de caractères
    cmp ecx, 20                                        ; Compare avec la limite de 20 caractères pour le nom
    jge parse_done_fail                                ; Si ≥ 20, nom trop long, échec
    cmp ecx, [input_length]                            ; Compare avec la longueur totale de l’entrée lue
    jl find_space_loop                                 ; Si inférieur, continue la boucle
    jmp parse_done_fail                                ; Si fin atteinte sans espace, échec

found_space:
    cmp ecx, 0                                         ; Vérifie si le nom est vide (aucun caractère avant l’espace)
    je parse_done_fail                                 ; Si vide, échec
    push ecx                                           ; Sauvegarde la longueur du nom sur la pile
    mov edx, ecx                                       ; Copie la longueur dans EDX pour la boucle de copie

copy_name_loop:
    mov al, [esi]                                      ; Charge le caractère courant du nom dans AL
    mov [edi], al                                      ; Stocke le caractère dans le tableau personnes
    inc esi                                            ; Passe au caractère suivant dans l’entrée
    inc edi                                            ; Passe à l’emplacement suivant dans personnes
    dec edx                                            ; Décrémente le compteur de caractères restants
    jnz copy_name_loop                                 ; Continue la boucle si EDX n’est pas zéro
    mov byte [edi], 0                                  ; Ajoute un zéro terminateur après le nom

    pop ecx                                            ; Restaure la longueur du nom depuis la pile
    inc ecx                                            ; Incrémente ECX pour passer l’espace et pointer vers l’âge
    lea esi, [input + ecx]                             ; Charge l’adresse du début de l’âge dans ESI
    call convert_age                                   ; Appelle la fonction pour convertir l’âge en entier
    cmp ebx, 0                                         ; Vérifie si l’âge est 0 (invalide)
    je parse_done_fail                                 ; Si 0, échec
    cmp ebx, 120                                       ; Vérifie si l’âge dépasse 120 (invalide)
    jg parse_done_fail                                 ; Si > 120, échec

    mov eax, [count]                                   ; Charge le nombre actuel de personnes dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour calculer l’offset dans ages (4 octets par âge)
    mov [ages + eax], ebx                              ; Stocke l’âge converti dans le tableau ages
    inc dword [count]                                  ; Incrémente le compteur de personnes
    mov eax, 1                                         ; Met EAX à 1 pour indiquer un succès
    ret                                                ; Retourne de la fonction

parse_done_fail:
    mov eax, 0                                         ; Met EAX à 0 pour indiquer un échec
    ret                                                ; Retourne de la fonction

; Convertit une chaîne de chiffres en entier
convert_age:
    xor ebx, ebx                                       ; Réinitialise EBX à 0 pour accumuler l’âge
    xor eax, eax                                       ; Réinitialise EAX à 0 pour les calculs temporaires
convert_loop:
    mov al, [esi]                                      ; Charge le caractère courant dans AL
    cmp al, 10                                         ; Compare avec LF (fin de l’âge)
    je convert_done                                    ; Si LF, termine la conversion
    cmp al, 0                                          ; Compare avec zéro (fin de l’âge)
    je convert_done                                    ; Si zéro, termine la conversion
    cmp al, '0'                                        ; Compare avec '0' pour vérifier si c’est un chiffre
    jb convert_error                                   ; Si inférieur à '0', erreur (pas un chiffre)
    cmp al, '9'                                        ; Compare avec '9' pour vérifier si c’est un chiffre
    ja convert_error                                   ; Si supérieur à '9', erreur (pas un chiffre)
    sub al, '0'                                        ; Soustrait '0' pour convertir le caractère en valeur numérique (0-9)
    imul ebx, 10                                       ; Multiplie l’accumulateur (EBX) par 10 pour décaler les chiffres
    add ebx, eax                                       ; Ajoute la nouvelle valeur au total
    inc esi                                            ; Passe au caractère suivant dans la chaîne
    jmp convert_loop                                   ; Continue la boucle

convert_error:
    mov ebx, 0                                         ; Met EBX à 0 en cas d’erreur (âge invalide)
convert_done:
    ret                                                ; Retourne de la fonction avec l’âge dans EBX

; Liste toutes les personnes enregistrées
list_people:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, list_header                               ; Pointeur vers l’en-tête de la liste
    mov edx, list_header_len                           ; Longueur de l’en-tête
    int 0x80                                           ; Affiche "Liste des personnes:" avec LF

    mov eax, [count]                                   ; Charge le nombre de personnes dans EAX
    cmp eax, 0                                         ; Vérifie si le compteur est à 0
    je no_people_registered                            ; Si 0, saute à no_people_registered (liste vide)

    xor esi, esi                                       ; Initialise l’index (ESI) à 0 pour parcourir les personnes
display_loop:
    mov ecx, num_buffer                                ; Charge l’adresse de num_buffer dans ECX pour l’effacer
    mov edx, 11                                        ; Définit la taille de num_buffer (11 octets) comme compteur
clear_num_buffer_list_loop:
    mov byte [ecx], 0                                  ; Met l’octet courant à zéro
    inc ecx                                            ; Passe à l’octet suivant
    dec edx                                            ; Décrémente le compteur
    jnz clear_num_buffer_list_loop                     ; Continue la boucle si EDX n’est pas zéro

    mov ebx, esi                                       ; Charge l’index courant dans EBX
    inc ebx                                            ; Incrémente EBX pour affichage (numérotation commence à 1)
    call print_number                                  ; Appelle la fonction pour afficher le numéro de la personne

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace après le numéro

    mov eax, esi                                       ; Charge l’index courant dans EAX
    imul eax, 64                                       ; Multiplie par 64 pour calculer l’offset dans personnes
    lea ecx, [personnes + eax]                         ; Charge l’adresse du nom dans ECX
    push ecx                                           ; Sauvegarde l’adresse du nom sur la pile
    xor edx, edx                                       ; Initialise le compteur de longueur à 0

find_name_length:
    cmp byte [ecx + edx], 0                            ; Compare l’octet courant du nom avec zéro (fin de chaîne)
    je name_length_done                                ; Si zéro, termine le calcul de la longueur
    inc edx                                            ; Incrémente le compteur de caractères
    cmp edx, 20                                        ; Compare avec la limite de 20 caractères
    jl find_name_length                                ; Si < 20, continue la boucle
name_length_done:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    int 0x80                                           ; Affiche le nom (EDX contient la longueur calculée)
    pop ecx                                            ; Restaure l’adresse du nom depuis la pile

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace après le nom

    mov eax, esi                                       ; Charge l’index courant dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour calculer l’offset dans ages
    mov ebx, [ages + eax]                              ; Charge l’âge correspondant dans EBX
    call print_number                                  ; Appelle la fonction pour afficher l’âge

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, newline                                   ; Pointeur vers le caractère LF
    mov edx, 1                                         ; Longueur du saut de ligne (1 octet)
    int 0x80                                           ; Affiche un saut de ligne après chaque personne

    inc esi                                            ; Incrémente l’index pour passer à la personne suivante
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jl display_loop                                    ; Si inférieur, continue la boucle
    jmp display_menu                                   ; Retourne au menu principal

no_people_registered:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, no_data_msg                               ; Pointeur vers le message de liste vide
    mov edx, no_data_len                               ; Longueur du message
    int 0x80                                           ; Affiche "Aucune personne n’est encore enregistrée!" avec LF
    jmp display_menu                                   ; Retourne au menu principal

; Supprime une personne spécifique
delete_person:
    mov eax, [count]                                   ; Charge le nombre de personnes dans EAX
    cmp eax, 0                                         ; Vérifie si le compteur est à 0
    je no_people_registered                            ; Si 0, saute à no_people_registered (rien à supprimer)

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, prompt_delete                             ; Pointeur vers l’invite de suppression
    mov edx, prompt_delete_len                         ; Longueur de l’invite
    int 0x80                                           ; Affiche "Suppression la personne (numero): "

    mov ecx, input                                     ; Charge l’adresse du tampon input dans ECX pour l’effacer
    mov edx, 256                                       ; Définit la taille du tampon (256 octets) comme compteur
clear_input_delete_loop:
    mov byte [ecx], 0                                  ; Met l’octet courant à zéro
    inc ecx                                            ; Passe à l’octet suivant
    dec edx                                            ; Décrémente le compteur
    jnz clear_input_delete_loop                        ; Continue la boucle si EDX n’est pas zéro

    mov eax, 3                                         ; Appel système sys_read
    mov ebx, 0                                         ; Descripteur de fichier stdin
    mov ecx, input                                     ; Pointeur vers le tampon input
    mov edx, 255                                       ; Nombre max d’octets à lire
    int 0x80                                           ; Lit le numéro de la personne à supprimer
    mov [input_length], eax                            ; Stocke la longueur lue dans input_length

    mov esi, input                                     ; Charge l’adresse de l’entrée dans ESI
    call convert_age                                   ; Convertit la chaîne en entier (réutilise convert_age)
    mov edi, ebx                                       ; Sauvegarde le numéro original dans EDI
    dec ebx                                            ; Décrémente EBX pour passer à un index 0-based

    cmp ebx, 0                                         ; Vérifie si l’index est < 0 (invalide)
    jl delete_not_found                                ; Si inférieur, saute à delete_not_found
    cmp ebx, [count]                                   ; Compare avec le nombre total de personnes
    jge delete_not_found                               ; Si ≥ count, saute à delete_not_found

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, delete_success                            ; Pointeur vers le début du message de suppression
    mov edx, delete_success_len                        ; Longueur du message "Personne "
    int 0x80                                           ; Affiche "Personne "

    mov ebx, edi                                       ; Charge le numéro original dans EBX (1-based)
    call print_number                                  ; Affiche le numéro de la personne

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    mov eax, edi                                       ; Charge le numéro original dans EAX
    dec eax                                            ; Décrémente pour passer à un index 0-based
    imul eax, 64                                       ; Multiplie par 64 pour calculer l’offset dans personnes
    lea ecx, [personnes + eax]                         ; Charge l’adresse du nom dans ECX
    push ecx                                           ; Sauvegarde l’adresse sur la pile
    xor edx, edx                                       ; Initialise le compteur de longueur à 0

find_delete_name_length:
    cmp byte [ecx + edx], 0                            ; Compare l’octet courant du nom avec zéro
    je delete_name_length_done                         ; Si zéro, termine le calcul de la longueur
    inc edx                                            ; Incrémente le compteur
    cmp edx, 20                                        ; Compare avec la limite de 20 caractères
    jl find_delete_name_length                         ; Si < 20, continue la boucle
delete_name_length_done:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    int 0x80                                           ; Affiche le nom (EDX contient la longueur)
    pop ecx                                            ; Restaure l’adresse du nom

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, delete_success_end                        ; Pointeur vers la fin du message de suppression
    mov edx, delete_success_end_len                    ; Longueur du message " a ete supprimee!" avec LF
    int 0x80                                           ; Affiche la fin du message avec LF

    mov esi, edi                                       ; Charge l’index de départ (1-based) dans ESI
    dec esi                                            ; Décrémente pour passer à 0-based
    inc esi                                            ; Incrémente pour pointer vers l’entrée suivante
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jge shift_done                                     ; Si ≥ count, termine le décalage

shift_loop:
    mov eax, esi                                       ; Charge l’index source dans EAX
    dec eax                                            ; Décrémente pour calculer l’index destination
    imul eax, 64                                       ; Multiplie par 64 pour l’offset destination dans personnes
    imul edx, esi, 64                                  ; Multiplie ESI par 64 pour l’offset source dans personnes
    lea edi, [personnes + eax]                         ; Charge l’adresse destination dans EDI
    lea ecx, [personnes + edx]                         ; Charge l’adresse source dans ECX
    push ecx                                           ; Sauvegarde l’adresse source sur la pile
    xor edx, edx                                       ; Initialise le compteur de longueur à 0

find_shift_length:
    cmp byte [ecx + edx], 0                            ; Compare l’octet courant avec zéro
    je shift_length_done                               ; Si zéro, termine le calcul de la longueur
    inc edx                                            ; Incrémente le compteur
    cmp edx, 20                                        ; Compare avec la limite de 20 caractères
    jl find_shift_length                               ; Si < 20, continue la boucle
shift_length_done:
    inc edx                                            ; Incrémente EDX pour inclure le zéro terminateur

shift_copy_loop:
    mov al, [ecx]                                      ; Charge l’octet source dans AL
    mov [edi], al                                      ; Copie l’octet dans la destination
    inc ecx                                            ; Passe à l’octet suivant dans la source
    inc edi                                            ; Passe à l’octet suivant dans la destination
    dec edx                                            ; Décrémente le compteur
    jnz shift_copy_loop                                ; Continue la boucle si EDX n’est pas zéro
    pop ecx                                            ; Restaure l’adresse source

    mov eax, esi                                       ; Charge l’index source dans EAX
    dec eax                                            ; Décrémente pour l’index destination
    imul eax, 4                                        ; Multiplie par 4 pour l’offset destination dans ages
    imul edx, esi, 4                                   ; Multiplie ESI par 4 pour l’offset source dans ages
    mov ecx, [ages + edx]                              ; Charge l’âge source dans ECX
    mov [ages + eax], ecx                              ; Copie l’âge dans la destination

    inc esi                                            ; Passe à l’entrée suivante
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jl shift_loop                                      ; Si inférieur, continue la boucle

shift_done:
    dec dword [count]                                  ; Décrémente le compteur de personnes
    mov eax, [count]                                   ; Charge le nouvel index dans EAX
    imul eax, 64                                       ; Multiplie par 64 pour l’offset de la dernière entrée
    lea edi, [personnes + eax]                         ; Charge l’adresse de la dernière entrée dans EDI
    mov ecx, 64                                        ; Définit la taille d’une entrée (64 octets) comme compteur
clear_last_entry:
    mov byte [edi], 0                                  ; Met l’octet courant à zéro
    inc edi                                            ; Passe à l’octet suivant
    dec ecx                                            ; Décrémente le compteur
    jnz clear_last_entry                               ; Continue la boucle si ECX n’est pas zéro
    mov eax, [count]                                   ; Charge le nouvel index dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour l’offset dans ages
    mov dword [ages + eax], 0                          ; Efface le dernier âge en mettant à 0
    jmp display_menu                                   ; Retourne au menu principal

delete_not_found:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, delete_fail                               ; Pointeur vers le message d’échec
    mov edx, delete_fail_len                           ; Longueur du message
    int 0x80                                           ; Affiche "Cette personne n’existe pas!" avec LF
    jmp display_menu                                   ; Retourne au menu principal

; Affiche les personnes avec les âges maximum et minimum
show_extremes:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, extremes_header                           ; Pointeur vers l’en-tête des âges extrêmes
    mov edx, extremes_header_len                       ; Longueur de l’en-tête
    int 0x80                                           ; Affiche "Plus agee et plus jeune:" avec LF

    mov eax, [count]                                   ; Charge le nombre de personnes dans EAX
    cmp eax, 0                                         ; Vérifie si le compteur est à 0
    je no_people_registered                            ; Si 0, saute à no_people_registered

    xor esi, esi                                       ; Initialise l’index à 0
    mov ebx, [ages]                                    ; Initialise l’âge maximum au premier âge
    mov edx, ebx                                       ; Initialise l’âge minimum au premier âge
    xor edi, edi                                       ; Initialise l’index du max à 0
    xor ecx, ecx                                       ; Initialise l’index du min à 0

find_extremes_loop:
    mov eax, esi                                       ; Charge l’index courant dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour l’offset dans ages
    mov eax, [ages + eax]                              ; Charge l’âge courant dans EAX
    cmp eax, ebx                                       ; Compare avec l’âge maximum actuel
    jle check_min                                      ; Si ≤ max, passe à la vérification du min
    mov ebx, eax                                       ; Met à jour l’âge maximum
    mov edi, esi                                       ; Met à jour l’index du max

check_min:
    cmp eax, edx                                       ; Compare avec l’âge minimum actuel
    jge next_extreme                                   ; Si ≥ min, passe à l’itération suivante
    mov edx, eax                                       ; Met à jour l’âge minimum
    mov ecx, esi                                       ; Met à jour l’index du min

next_extreme:
    inc esi                                            ; Incrémente l’index pour la prochaine personne
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jl find_extremes_loop                              ; Si inférieur, continue la boucle

    push edi                                           ; Sauvegarde l’index du max sur la pile
    push ecx                                           ; Sauvegarde l’index du min sur la pile

    mov esi, edi                                       ; Charge l’index du max dans ESI
    mov ebx, esi                                       ; Copie l’index dans EBX
    inc ebx                                            ; Incrémente pour affichage (1-based)
    call print_number                                  ; Affiche le numéro de la personne la plus âgée

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    imul eax, esi, 64                                  ; Multiplie l’index par 64 pour l’offset dans personnes
    lea ecx, [personnes + eax]                         ; Charge l’adresse du nom dans ECX
    push ecx                                           ; Sauvegarde l’adresse sur la pile
    xor edx, edx                                       ; Initialise le compteur de longueur à 0

find_max_name_length:
    cmp byte [ecx + edx], 0                            ; Compare l’octet courant avec zéro
    je max_name_length_done                            ; Si zéro, termine le calcul de la longueur
    inc edx                                            ; Incrémente le compteur
    cmp edx, 20                                        ; Compare avec la limite de 20 caractères
    jl find_max_name_length                            ; Si < 20, continue la boucle
max_name_length_done:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    int 0x80                                           ; Affiche le nom (EDX contient la longueur)
    pop ecx                                            ; Restaure l’adresse du nom

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    imul eax, esi, 4                                   ; Multiplie l’index par 4 pour l’offset dans ages
    mov ebx, [ages + eax]                              ; Charge l’âge maximum dans EBX
    call print_number                                  ; Affiche l’âge maximum

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, newline                                   ; Pointeur vers le caractère LF
    mov edx, 1                                         ; Longueur du saut de ligne (1 octet)
    int 0x80                                           ; Affiche un saut de ligne

    pop esi                                            ; Restaure l’index du min depuis la pile
    mov ebx, esi                                       ; Copie l’index dans EBX
    inc ebx                                            ; Incrémente pour affichage (1-based)
    call print_number                                  ; Affiche le numéro de la personne la plus jeune

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    imul eax, esi, 64                                  ; Multiplie l’index par 64 pour l’offset dans personnes
    lea ecx, [personnes + eax]                         ; Charge l’adresse du nom dans ECX
    push ecx                                           ; Sauvegarde l’adresse sur la pile
    xor edx, edx                                       ; Initialise le compteur de longueur à 0

find_min_name_length:
    cmp byte [ecx + edx], 0                            ; Compare l’octet courant avec zéro
    je min_name_length_done                            ; Si zéro, termine le calcul de la longueur
    inc edx                                            ; Incrémente le compteur
    cmp edx, 20                                        ; Compare avec la limite de 20 caractères
    jl find_min_name_length                            ; Si < 20, continue la boucle
min_name_length_done:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    int 0x80                                           ; Affiche le nom (EDX contient la longueur)
    pop ecx                                            ; Restaure l’adresse du nom

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    imul eax, esi, 4                                   ; Multiplie l’index par 4 pour l’offset dans ages
    mov ebx, [ages + eax]                              ; Charge l’âge minimum dans EBX
    call print_number                                  ; Affiche l’âge minimum

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, newline                                   ; Pointeur vers le caractère LF
    mov edx, 1                                         ; Longueur du saut de ligne (1 octet)
    int 0x80                                           ; Affiche un saut de ligne

    pop edi                                            ; Restaure l’index du max (non utilisé ici, juste pour nettoyer la pile)
    jmp display_menu                                   ; Retourne au menu principal

; Calcule et affiche l’âge moyen
show_average:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, avg_header                                ; Pointeur vers l’en-tête de l’âge moyen
    mov edx, avg_header_len                            ; Longueur de l’en-tête
    int 0x80                                           ; Affiche "Age en moyenne:" avec LF

    mov eax, [count]                                   ; Charge le nombre de personnes dans EAX
    cmp eax, 0                                         ; Vérifie si le compteur est à 0
    je no_people_registered                            ; Si 0, saute à no_people_registered

    xor esi, esi                                       ; Initialise l’index à 0
    xor ebx, ebx                                       ; Initialise la somme des âges à 0

sum_ages_loop:
    mov eax, esi                                       ; Charge l’index courant dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour l’offset dans ages
    add ebx, [ages + eax]                              ; Ajoute l’âge courant à la somme dans EBX
    inc esi                                            ; Incrémente l’index
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jl sum_ages_loop                                   ; Si inférieur, continue la boucle

    mov eax, ebx                                       ; Charge la somme dans EAX pour la division
    xor edx, edx                                       ; Réinitialise EDX à 0 (pour la division)
    idiv dword [count]                                 ; Divise EAX par le nombre de personnes, quotient dans EAX
    mov ebx, eax                                       ; Stocke la moyenne dans EBX
    call print_number                                  ; Affiche la moyenne

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, avg_open                                  ; Pointeur vers la parenthèse ouvrante
    mov edx, 1                                         ; Longueur de la parenthèse (1 octet)
    int 0x80                                           ; Affiche "("

    xor esi, esi                                       ; Réinitialise l’index à 0 pour lister les âges
list_ages_loop:
    mov eax, esi                                       ; Charge l’index courant dans EAX
    imul eax, 4                                        ; Multiplie par 4 pour l’offset dans ages
    mov ebx, [ages + eax]                              ; Charge l’âge courant dans EBX
    call print_number                                  ; Affiche l’âge

    inc esi                                            ; Incrémente l’index
    cmp esi, [count]                                   ; Compare avec le nombre total de personnes
    jge list_ages_done                                 ; Si ≥ count, termine la liste
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, space                                     ; Pointeur vers le caractère espace
    mov edx, 1                                         ; Longueur de l’espace (1 octet)
    int 0x80                                           ; Affiche un espace entre les âges
    jmp list_ages_loop                                 ; Continue la boucle

list_ages_done:
    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov ecx, avg_close                                 ; Pointeur vers la parenthèse fermante avec LF
    mov edx, 1                                         ; Longueur (1 octet pour ")", LF est inclus dans la chaîne)
    int 0x80                                           ; Affiche ")" avec LF
    jmp display_menu                                   ; Retourne au menu principal

; Convertit un entier en texte et l’affiche
print_number:
    push ecx                                           ; Sauvegarde ECX sur la pile
    push edx                                           ; Sauvegarde EDX sur la pile
    mov ecx, num_buffer + 10                           ; Pointe vers la fin de num_buffer (dernier octet)
    mov byte [ecx], 0                                  ; Ajoute un zéro terminateur à la fin
    dec ecx                                            ; Recule d’un octet pour commencer à écrire
    mov eax, ebx                                       ; Charge le nombre à convertir dans EAX

print_convert_loop:
    xor edx, edx                                       ; Réinitialise EDX à 0 pour la division
    mov ebx, 10                                        ; Définit le diviseur à 10 (base décimale)
    div ebx                                            ; Divise EAX par 10, quotient dans EAX, reste dans EDX
    add dl, '0'                                        ; Convertit le reste (0-9) en caractère ASCII ('0'-'9')
    mov [ecx], dl                                      ; Stocke le caractère dans num_buffer
    dec ecx                                            ; Recule d’un octet dans num_buffer
    test eax, eax                                      ; Vérifie si le quotient est 0
    jnz print_convert_loop                             ; Si différent de 0, continue la boucle
    inc ecx                                            ; Repositionne ECX sur le premier caractère du nombre

    mov eax, 4                                         ; Appel système sys_write
    mov ebx, 1                                         ; Descripteur de fichier stdout
    mov edx, num_buffer + 10                           ; Pointe vers la fin de num_buffer
    sub edx, ecx                                       ; Calcule la longueur du texte à afficher
    int 0x80                                           ; Affiche le nombre converti
    pop edx                                            ; Restaure EDX depuis la pile
    pop ecx                                            ; Restaure ECX depuis la pile
    ret                                                ; Retourne de la fonction

; Quitte le programme
exit_program:
    mov eax, 1                                         ; Appel système sys_exit (1)
    xor ebx, ebx                                       ; Code de retour 0 (succès)
    int 0x80                                           ; Interruption pour terminer le programme