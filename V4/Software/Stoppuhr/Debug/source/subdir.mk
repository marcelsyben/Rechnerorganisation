################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../source/Stoppuhr.S 

OBJS += \
./source/Stoppuhr.o 


# Each subdirectory must supply rules for building sources it contributes
source/%.o: ../source/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Assembler'
	mips-sde-elf-as -EL -g -gstabs+ -mips32r2  -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


