package main

import (
	"context"
	"exv/modules"
	"log"
)

func main() {
	ctx := context.Background()
	client, err := modules.ConfigureFirebase(ctx, "./hubapp.json")
	if err != nil {
		log.Fatalf("erro ao configurar o Firebase: %v\n", err)
	}

	notif := modules.AppNotification{
		Title: "Olá do Go!",
		Body:  "Esta é uma notificação enviada do nosso servidor Go!",
		Token: "dBzbyoOZRrye-_jn3APqSd:APA91bEv_nSGAv6yBA-MgyoZCi52DqbYh5t4K-pb13t3r2iggOroup1pKqoR3js5kWBp55zmmo8cl95CP1y02GeZqG0l_a02MWsy7UCZBz8-jXCUR6et7ec",
		Data:  map[string]string{"route": "/ptd/loans"},
	}

	response, err := modules.SendNotification(ctx, client, notif)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("Notificação enviada com sucesso:", response)

	loans, err := modules.FetchLoans()
	if err != nil {
		log.Fatalf("erro ao buscar empréstimos: %v\n", err)
	}

	log.Println("Empréstimos encontrados:", loans)
}
