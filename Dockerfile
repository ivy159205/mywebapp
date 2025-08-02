# Giai đoạn 1: Build ứng dụng
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyWebApp.csproj", "./"]
RUN dotnet restore "./MyWebApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "MyWebApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyWebApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Giai đoạn 2: Tạo image cuối cùng, nhẹ hơn
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
# Mở cổng 8080 cho container
EXPOSE 8080
# Lệnh để khởi chạy ứng dụng khi container bắt đầu
ENTRYPOINT ["dotnet", "MyWebApp.dll"]