# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

# Build argument for target architecture
ARG TARGETARCH
ARG RUNTIME_ID=linux-${TARGETARCH}

# Install native build tools required for AOT
RUN apt-get update && apt-get install -y clang zlib1g-dev

WORKDIR /app

# Copy source code
COPY AppInsightsCustomSamplingApi/ AppInsightsCustomSamplingApi/
WORKDIR /app/AppInsightsCustomSamplingApi

# Restore and publish in one step
RUN dotnet publish -c Release -o /app/publish -r ${RUNTIME_ID}

# Runtime stage - use runtime-deps for AOT
FROM mcr.microsoft.com/dotnet/runtime-deps:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Expose port
EXPOSE 8080

ENTRYPOINT ["./AppInsightsCustomSamplingApi"]