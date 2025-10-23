VAGRANT_DIR := infrastructure

.PHONY: help vm-up vm-halt vm-destroy vm-status vm-ssh vm-reload vm-provision vm-resume vm-suspend

help:
	@echo "Comandos disponibles:"
	@echo "  make vm-up         # Inicia la máquina virtual"
	@echo "  make vm-halt       # Detiene la máquina virtual"
	@echo "  make vm-destroy    # Destruye la máquina virtual"
	@echo "  make vm-status     # Muestra el estado de la máquina virtual"
	@echo "  make vm-ssh        # Abre una sesión SSH en la VM"
	@echo "  make vm-reload     # Reinicia la VM (halt + up)"
	@echo "  make vm-provision  # Reaplica el aprovisionamiento"
	@echo "  make vm-resume     # Reanuda la VM si está suspendida"
	@echo "  make vm-suspend    # Suspende la VM"

vm-up:
	cd $(VAGRANT_DIR) && vagrant up

vm-halt:
	cd $(VAGRANT_DIR) && vagrant halt

vm-destroy:
	cd $(VAGRANT_DIR) && vagrant destroy -f

vm-status:
	cd $(VAGRANT_DIR) && vagrant status

vm-ssh:
	cd $(VAGRANT_DIR) && vagrant ssh

vm-reload:
	cd $(VAGRANT_DIR) && vagrant reload

vm-provision:
	cd $(VAGRANT_DIR) && vagrant provision

vm-resume:
	cd $(VAGRANT_DIR) && vagrant resume

vm-suspend:
	cd $(VAGRANT_DIR) && vagrant suspend
