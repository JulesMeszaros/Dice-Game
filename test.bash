# Sauvegarde
        cp src/classes/FaceTypes.lua{,.bak}

        # On supprime d'abord les tier statiques déjà insérés (au cas où on ré-exécute)
        sed -i '' '/^[A-Za-z0-9_]*\.tier =/d' src/classes/FaceTypes.lua

        # Pour chaque définition de classe, on récupère le tier du constructeur et on l'insère après la ligne __index
        grep -E 'local [A-Za-z0-9_]+ = setmetatable\(\{\}, \{ __index = FaceObject \}\)' src/classes/FaceTypes.lua \
          | awk '{print $2}' \
          | while read cls; do
              tier=$(grep -A5 "function $cls:new" src/classes/FaceTypes.lua \
                       | grep 'self.tier' \
                       | sed -E 's/.*self.tier *= *"([^"]+)".*/\1/')
              if [ -n "$tier" ]; then
                sed -i '' "/$cls\.__index = $cls/a\\
        $cls.tier = \"$tier\"
        " src/classes/FaceTypes.lua
              fi
          done

        # Vous pouvez vérifier le résultat et, si tout est OK, supprimer le bak :
        # mv src/classes/FaceTypes.lua.bak src/classes/FaceTypes.lua.bak.save
