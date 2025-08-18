package main

import (
	"context"
	"exv/modules"
	"log"
	"time"
)

func main() {
	ctx := context.Background()
	client, err := modules.ConfigureFirebase(ctx, "./hubapp.json")
	if err != nil {
		log.Fatalf("erro ao configurar o Firebase: %v\n", err)
	}

	loans, err := modules.FetchLoans()
	if err != nil {
		log.Fatalf("erro ao buscar empréstimos: %v\n", err)
	}

	log.Println("Empréstimos encontrados:", loans)

	// Notificar empréstimos próximos do vencimento
	loansByToken := make(map[string][]modules.Loan)
	now := time.Now()
	for _, loan := range loans {
		returnDate, err := time.Parse("2006-01-02T15:04:05.000000Z", loan.ReturnDate)
		if err != nil {
			log.Printf("Data inválida para empréstimo %s: %v\n", loan.ID, err)
			continue
		}
		daysLeft := returnDate.Sub(now).Hours() / 24
		if daysLeft <= 7 && daysLeft >= 0 {
			loansByToken[loan.DeviceToken] = append(loansByToken[loan.DeviceToken], loan)
		}
	}

	// enviar caso de empréstimos próximos do vencimento
	for token, loans := range loansByToken {
		body := "Os seguintes empréstimos estão para finalizar:\n"
		for _, loan := range loans {
			returnDate, _ := time.Parse("2006-01-02T15:04:05.000000Z", loan.ReturnDate)
			formattedDate := returnDate.Format("02/01/2006")
			body += "- " + loan.Applicant + " (Vence em: " + formattedDate + ")\n"
		}
		notif := modules.AppNotification{
			Title: "Empréstimos próximos do vencimento",
			Body:  body,
			Token: token,
			Data:  map[string]string{"route": "/ptd/loans"},
		}
		response, err := modules.SendNotification(ctx, client, notif)
		if err != nil {
			log.Printf("Erro ao enviar notificação para %s: %v\n", token, err)
		} else {
			log.Printf("Notificação enviada para %s: %s\n", token, response)
		}
	}
}
