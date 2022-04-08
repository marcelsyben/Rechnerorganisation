################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include source/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: Erweiterte_Stoppuhr.elf

# Tool invocations
Erweiterte_Stoppuhr.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: Cross GCC Linker'
	mips-sde-elf-gcc -nostartfiles -nodefaultlibs -nostdlib -static -Xlinker -TC:/Users/Marcel/Desktop/V4_5/Software/Erweiterte_Stoppuhr/source/lscript.ld -Xlinker -EL -o "Erweiterte_Stoppuhr.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(C_DEPS) Erweiterte_Stoppuhr.elf
	-@echo ' '

post-build:
	-mips-sde-elf-objdump.exe -h -j.text -j.data -j.bss Erweiterte_Stoppuhr.elf & mips-sde-elf-objdump.exe -h -t -j.text -j.data -j.bss -S Erweiterte_Stoppuhr.elf > Erweiterte_Stoppuhr_diss.txt & mips-sde-elf-objcopy.exe -O ihex Erweiterte_Stoppuhr.elf Erweiterte_Stoppuhr.hex
	-@echo ' '

.PHONY: all clean dependents post-build

-include ../makefile.targets
