#include "controller.h"

#include <QFile>


namespace App
{

Controller::Controller(VkUserModel& model, QObject *parent)
    : QObject(parent)
    , model_(model)
    , qmlHandleObject_(nullptr)
{
    api_ = std::make_unique<VK::Client>("5.65", "ru",
                                        [this](const QString& id){ return enterCaptcha(id); },
                                        [this](){ return enterSMSCode(); });
}

bool Controller::auth(const QString &login, const QString &password)
{
    bool authResult = api_->auth(login, password);

    if (authResult)
        saveApiToken(api_->access_token());
    return authResult;
}

bool Controller::getLikes(const QString &url)
{
    if (url.contains("wall-", Qt::CaseInsensitive))
    {
        QStringList data = url.split("wall", QString::SkipEmptyParts);
        if (data.length() > 1)
        {
            data = data[data.length() - 1].split("_", QString::SkipEmptyParts);
            if (data.length() == 2)
            {
                QString groupId = data[0];
                QString postId = data[1];

                int offset = 0;
                int likesCount = 0;
                std::list<User> users;
                do
                {
                    QJsonObject response = api_->call("likes.getList", {
                                                       {"type",     "post"},
                                                       {"offset",   QString::number(offset)},
                                                       {"owner_id", groupId},
                                                       {"item_id",  postId},
                                                       {"count",    "1000"}
                                                   });
                    offset += 1000;
                    try
                    {
                        if (response.isEmpty())
                        {
                            qDebug() << "NO LIKES FOUND";
                            return false;
                        }
                        response = getValue<jsonObject>(response, "response");
                        likesCount = getValue<int>(response, "count");
                        jsonArray items = getValue<jsonArray>(response, "items");

                        QStringList userIds;
                        for (const auto& item: items)
                            userIds.push_back(QString::number(item.toInt()));
                        QString idLst = userIds.join(",");

                        response = api_->call("users.get", {
                                                {"user_ids", idLst},
                                                {"fields", "sex,city,home_town"},
                                            });
                        items = getValue<jsonArray>(response, "response");
                        for (const auto& item: items)
                        {
                            jsonObject userObj = item.toObject();
                            User user;
                            if (userObj.contains("first_name") && userObj.contains("last_name"))
                                user.fullName = getValue<QString>(userObj, "first_name") + " " + getValue<QString>(userObj, "last_name");
                            if (userObj.contains("id"))
                                user.id = getValue<int>(userObj, "id");
                            if (userObj.contains("city") && userObj["city"].toObject().contains("title"))
                                user.cityName = getValue<QString>(getValue<jsonObject>(userObj, "city"), "title");
                            if (userObj.contains("home_town"))
                                user.homeTown = getValue<QString>(userObj, "home_town");
                            if (userObj.contains("sex"))
                                user.sex = getValue<int>(userObj, "sex");
                            users.push_back(user);
                        }
                    }
                    catch (const std::exception& ex)
                    {
                        qWarning() << ex.what();
                        return false;
                    }
                }
                while (offset < likesCount);
                model_.setUsers(users);
                return true;
            }
        }
    }
    return false;
}

void Controller::setFiltersAndAddUsers(int gender, int sortBy, const QString &cityNames)
{
    QStringList rawCityToFilter = cityNames.simplified().split(",", QString::SkipEmptyParts);
    QStringList cityToFilter;

    for (const auto& city: rawCityToFilter)
        cityToFilter.push_back(city.simplified());

    model_.setFilters(gender, SortType(sortBy), cityToFilter);
    model_.addUsersToModel();
}

void Controller::closeApp()
{
    exit(0);
}

bool Controller::tryAutologin()
{
    return api_->auth("", "", loadApiToken());
}

QString Controller::getUsername()
{
    return api_->first_name();
}

void Controller::setQmlHandleObject(QObject *obj)
{
    qmlHandleObject_ = obj;
}

void Controller::saveApiToken(const QString& token)
{
    QFile tokenFile("vk_token");

    if (tokenFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        tokenFile.write(token.toUtf8());
        tokenFile.close();
    }
}

QString Controller::loadApiToken()
{
    QFile tokenFile("vk_token");

    if (tokenFile.open(QIODevice::ReadOnly))
    {
        return tokenFile.readLine().simplified();
    }
    return QString();
}

QString Controller::enterCaptcha(const QString &id)
{
    qDebug() << "Enter captcha!";
    if (qmlHandleObject_ == nullptr)
    {
        qCritical() << "No qmlHandleObject_ exiting!";
        return "";
    }

//    QVariant url = "https://api.vk.com/captcha.php?sid=" + id;
    QVariant url = id;
    QMetaObject::invokeMethod(qmlHandleObject_, "goToInput",
        Q_ARG(QVariant, url));

    QEventLoop loop;
    connect(&loop, &QEventLoop::quit, this, &Controller::codeChanged);
    loop.exec();

    return code_;
}

QString Controller::enterSMSCode()
{
    if (qmlHandleObject_ == nullptr)
    {
        qCritical() << "No qmlHandleObject_ exiting!";
        return "";
    }

    QMetaObject::invokeMethod(qmlHandleObject_, "goToInput",
        Q_ARG(QVariant, ""));

    QEventLoop loop;
    connect(this, &Controller::codeChanged, &loop, &QEventLoop::quit);
    loop.exec();

    return code_;
}

} // App
