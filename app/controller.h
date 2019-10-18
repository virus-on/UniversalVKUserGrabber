#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

#include <memory>

#include "api.h"
#include "vkUserModel.h"

struct User
{
    QString fullName;
    size_t  id = 0;
    int     sex = 2;  // male by default
    QString cityName;
    QString homeTown;
};

class Controller : public QObject
{
    Q_OBJECT
public:
    enum sortType {
        name = 0,
        city = 1,
        id = 2
    };

    explicit Controller(VkUserModel& model, QObject *parent = nullptr);
    Q_INVOKABLE bool auth(const QString& login, const QString& password);
    Q_INVOKABLE bool getLikes(const QString& url);
    Q_INVOKABLE void setFilter(const QString& gender = "", const sortType& sortBy = name, const QString& cityName = "");

private:
    std::unique_ptr<VK::Client> api_;
    VkUserModel&                model_;
};

#endif // CONTROLLER_H
