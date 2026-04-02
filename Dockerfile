# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Копіюємо файл проєкту та відновлюємо залежності (аналог mvn install)
COPY ["SampleWebApiAspNetCore/SampleWebApiAspNetCore.csproj", "SampleWebApiAspNetCore/"]
RUN dotnet restore "SampleWebApiAspNetCore/SampleWebApiAspNetCore.csproj"

# Копіюємо решту файлів і збираємо Release
COPY . .
WORKDIR "/src/SampleWebApiAspNetCore"
RUN dotnet build "SampleWebApiAspNetCore.csproj" -c Release -o /app/build

# Публікація (аналог створення jar-файла)
FROM build AS publish
RUN dotnet publish "SampleWebApiAspNetCore.csproj" -c Release -o /app/publish

# Stage 2: Final image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Налаштовуємо змінні середовища, щоб ASP.NET знав, який порт слухати
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "SampleWebApiAspNetCore.dll"]